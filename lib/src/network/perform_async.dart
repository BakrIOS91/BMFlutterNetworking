/// Async Network Operations for BMFlutter Networking Layer
///
/// When a 401 Unauthorized response is received on an [isAuthorized] request,
/// the layer automatically attempts a token refresh via [TokenRefreshRegistry].
/// If the refresh succeeds the original request is rebuilt (fresh token from
/// [authHeaders]) and re-sent exactly once. If the refresh fails the
/// [Unauthorized] error propagates normally.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bm_flutter_networking/src/helpers/api_error.dart';
import 'package:bm_flutter_networking/src/helpers/enums.dart';
import 'package:bm_flutter_networking/src/helpers/models/downloaded_file.dart';
import 'package:bm_flutter_networking/src/network/request.dart';
import 'package:bm_flutter_networking/src/network/target_request.dart';
import 'package:bm_flutter_networking/src/network/token_refresh_handler.dart';
import 'package:bm_flutter_networking/src/platform/file_io.dart';
import 'core/cancel_token.dart';
import 'core/http_client_factory.dart';
import 'core/interceptor.dart';
import 'core/network_config.dart';
import 'core/request_guard.dart';
import 'core/interceptors/logging_interceptor.dart';
import 'core/interceptors/auth_interceptor.dart';
import 'core/network_response.dart';
import 'error_handler.dart';

// ---------------------------------------------------------------------------
// Shared execution
// ---------------------------------------------------------------------------

/// Methods that cannot change server state.
bool _isReadOnly(HTTPMethod method) =>
    method == HTTPMethod.get ||
    method == HTTPMethod.head ||
    method == HTTPMethod.options;

/// Runs [body] with a configured client, timeouts, cancellation and
/// connection-loss detection, and maps every failure to an [APIError].
Future<R> _execute<R>(
  TargetRequest target,
  CancelToken? cancelToken,
  Future<R> Function(NetworkClient client, http.BaseRequest request) body,
) async {
  if (cancelToken != null && cancelToken.isCancelled) {
    throw const APIError(APIErrorType.cancelled);
  }
  // Checked before anything is built or sent, so an offline request is never
  // queued and cannot fire later.
  if (!await TargetRequest.isConnectedToInternet) {
    throw const APIError(APIErrorType.noNetwork);
  }

  final httpClient = createHttpClient(
    connectTimeout: target.connectTimeout ?? NetworkConfig.connectTimeout,
  );
  late final RequestGuard guard;
  late final NetworkClient networkClient;
  networkClient = NetworkClient(
    httpClient,
    interceptors: [
      AuthInterceptor(
        isAuthorized: target.isAuthorized,
        refreshRequest: () async {
          await TokenRefreshRegistry.refreshToken();
          return target.createRequest();
        },
        retry: (req) => networkClient.send(req),
        // A request that was cancelled or dropped is never replayed.
        shouldRetry: () => !guard.isAborted,
      ),
      LoggingInterceptor(),
    ],
  );
  guard = RequestGuard(
    isMutating: !_isReadOnly(target.requestMethod),
    cancelToken: cancelToken,
    onAbort: networkClient.close,
  );

  try {
    return await guard.run(() async {
      final request = await target.createRequest();
      return body(networkClient, request);
    });
  } on APIError {
    rethrow;
  } on TimeoutException {
    throw const APIError(APIErrorType.timeout);
  } on UnsupportedError {
    rethrow;
  } catch (_) {
    throw const APIError(APIErrorType.invalidResponse);
  } finally {
    guard.dispose();
    networkClient.close();
  }
}

/// Waits for the response headers, bounded by the send timeout.
Future<http.StreamedResponse> _send(
  TargetRequest target,
  NetworkClient client,
  http.BaseRequest request,
) {
  final limit = target.sendTimeout ?? NetworkConfig.sendTimeout;
  final future = client.send(request);
  return limit == null ? future : future.timeout(limit);
}

/// Reads the response body, bounded by the receive timeout.
Future<List<int>> _readBody(
  TargetRequest target,
  http.StreamedResponse response,
) {
  final limit = target.receiveTimeout ?? NetworkConfig.receiveTimeout;
  final future = response.stream.toBytes();
  return limit == null ? future : future.timeout(limit);
}

// ---------------------------------------------------------------------------
// ModelTargetType
// ---------------------------------------------------------------------------

extension PerformAsyncModelTargetType on ModelTargetType {
  /// Performs the request and returns the decoded model.
  ///
  /// Pass a [cancelToken] to cancel the request (e.g. when a screen closes).
  Future<Response> performAsync<Response>({CancelToken? cancelToken}) async {
    final response =
        await performAsyncWithCookies<Response>(cancelToken: cancelToken);
    return response.data;
  }

  Future<NetworkResponse<Response>> performAsyncWithCookies<Response>({
    CancelToken? cancelToken,
  }) {
    return _execute(this, cancelToken, (client, request) async {
      final streamedResponse = await _send(this, client, request);
      final statusCode = streamedResponse.statusCode;
      final statusCategory = HTTPStatusCode.from(statusCode);

      final responseData = await _readBody(this, streamedResponse);
      final rawSetCookie = streamedResponse.headers['set-cookie'];
      final cookies = parseSetCookieHeader(rawSetCookie);

      if (statusCategory == HTTPStatusCode.success) {
        return _decodeResponse<Response>(
          responseData: responseData,
          statusCode: statusCode,
          streamedResponse: streamedResponse,
          rawSetCookie: rawSetCookie,
          cookies: cookies,
        );
      }

      final errorModel = await _tryDecodeError(responseData);
      throw APIError(APIErrorType.httpError,
          statusCode: statusCategory, errorModel: errorModel);
    });
  }

  Future<DownloadedFile?> performDownload({CancelToken? cancelToken}) {
    return _execute(this, cancelToken, (client, request) async {
      final streamedResponse = await _send(this, client, request);
      final statusCode = streamedResponse.statusCode;
      final statusCategory = HTTPStatusCode.from(statusCode);
      final remoteUrl = streamedResponse.request?.url ?? request.url;

      if (statusCategory == HTTPStatusCode.notAuthorize) {
        throw APIError(APIErrorType.httpError, statusCode: statusCategory);
      }

      String fileName = remoteUrl.pathSegments.last;
      if (useUniqueFilename) {
        final timestamp = DateTime.now().microsecondsSinceEpoch;
        final hash = hashCode.toRadixString(16);
        fileName = '${timestamp}_${hash}_$fileName';
      }

      final savedUri =
          await saveStreamToTemp(fileName, streamedResponse.stream);

      if (statusCategory == HTTPStatusCode.success) {
        return DownloadedFile(
            downloadedUrl: savedUri,
            response: streamedResponse,
            remoteUrl: remoteUrl);
      }
      throw APIError(APIErrorType.httpError, statusCode: statusCategory);
    });
  }

  NetworkResponse<Response> _decodeResponse<Response>({
    required List<int> responseData,
    required int statusCode,
    required http.StreamedResponse streamedResponse,
    required String? rawSetCookie,
    required List<BMCookie> cookies,
  }) {
    try {
      final decodedJson = json.decode(utf8.decode(responseData));
      final data = fromDynamicJson(decodedJson);
      return NetworkResponse<Response>(
        data: data,
        statusCode: statusCode,
        headers: streamedResponse.headers,
        rawSetCookieHeader: rawSetCookie,
        cookies: cookies,
      );
    } catch (error) {
      if (kDebugMode) print(error);
      throw const APIError(APIErrorType.dataConversionFailed);
    }
  }
}

// ---------------------------------------------------------------------------
// SuccessTargetType
// ---------------------------------------------------------------------------

extension PerformAsyncSuccessTargetType on SuccessTargetType {
  Future<void> performAsync({CancelToken? cancelToken}) async {
    await performAsyncWithCookies(cancelToken: cancelToken);
  }

  Future<NetworkResponse<void>> performAsyncWithCookies({
    CancelToken? cancelToken,
  }) {
    return _execute(this, cancelToken, (client, request) async {
      final streamedResponse = await _send(this, client, request);
      final statusCode = streamedResponse.statusCode;
      final statusCategory = HTTPStatusCode.from(statusCode);

      final rawSetCookie = streamedResponse.headers['set-cookie'];
      final cookies = parseSetCookieHeader(rawSetCookie);

      if (statusCategory == HTTPStatusCode.success) {
        return NetworkResponse<void>(
          data: null,
          statusCode: statusCode,
          headers: streamedResponse.headers,
          rawSetCookieHeader: rawSetCookie,
          cookies: cookies,
        );
      }
      final responseData = await _readBody(this, streamedResponse);
      final errorModel = await _tryDecodeError(responseData);
      throw APIError(APIErrorType.httpError,
          statusCode: statusCategory, errorModel: errorModel);
    });
  }
}

Future<dynamic> _tryDecodeError(List<int> responseData) async {
  try {
    if (responseData.isEmpty) return null;
    final decodedJson = json.decode(utf8.decode(responseData));
    return APIErrorResponseRegistry.decode(decodedJson);
  } catch (_) {
    return null;
  }
}
