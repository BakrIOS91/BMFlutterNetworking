/// Async Network Operations for BMFlutter Networking Layer
///
/// When a 401 Unauthorized response is received on an [isAuthorized] request,
/// the layer automatically attempts a token refresh via [TokenRefreshRegistry].
/// If the refresh succeeds the original request is rebuilt (fresh token from
/// [authHeaders]) and re-sent exactly once. If the refresh fails the
/// [Unauthorized] error propagates normally.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bm_flutter_networking/src/helpers/api_error.dart';
import 'package:bm_flutter_networking/src/helpers/enums.dart';
import 'package:bm_flutter_networking/src/helpers/models/bm_cookie.dart';
import 'package:bm_flutter_networking/src/helpers/models/downloaded_file.dart';
import 'package:bm_flutter_networking/src/network/request.dart';
import 'package:bm_flutter_networking/src/network/target_request.dart';
import 'package:bm_flutter_networking/src/network/token_refresh_handler.dart';
import 'package:bm_flutter_networking/src/platform/file_io.dart';
import 'core/interceptor.dart';
import 'core/interceptors/logging_interceptor.dart';
import 'core/interceptors/auth_interceptor.dart';
import 'core/network_response.dart';
import 'error_handler.dart';

// ---------------------------------------------------------------------------
// ModelTargetType
// ---------------------------------------------------------------------------

extension PerformAsyncModelTargetType on ModelTargetType {
  Future<Response> performAsync<Response>() async {
    final response = await performAsyncWithCookies<Response>();
    return response.data;
  }

  Future<NetworkResponse<Response>> performAsyncWithCookies<Response>() async {
    if (!await TargetRequest.isConnectedToInternet) {
      throw const APIError(APIErrorType.noNetwork);
    }

    final httpClient = http.Client();
    late final NetworkClient networkClient;
    networkClient = NetworkClient(
      httpClient,
      interceptors: [
        AuthInterceptor(
          isAuthorized: isAuthorized,
          refreshRequest: () async {
            await TokenRefreshRegistry.refreshToken();
            return createRequest();
          },
          retry: (req) => networkClient.send(req),
        ),
        LoggingInterceptor(),
      ],
    );

    try {
      final request = await createRequest();
      final streamedResponse = await networkClient.send(request);
      final statusCode = streamedResponse.statusCode;
      final statusCategory = HTTPStatusCode.from(statusCode);

      final responseData = await streamedResponse.stream.toBytes();
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
    } catch (error) {
      if (error is APIError) rethrow;
      throw const APIError(APIErrorType.invalidResponse);
    } finally {
      networkClient.close();
    }
  }

  Future<DownloadedFile?> performDownload() async {
    if (!await TargetRequest.isConnectedToInternet) {
      throw const APIError(APIErrorType.noNetwork);
    }

    final httpClient = http.Client();
    late final NetworkClient networkClient;
    networkClient = NetworkClient(
      httpClient,
      interceptors: [
        AuthInterceptor(
          isAuthorized: isAuthorized,
          refreshRequest: () async {
            await TokenRefreshRegistry.refreshToken();
            return createRequest();
          },
          retry: (req) => networkClient.send(req),
        ),
        LoggingInterceptor(),
      ],
    );

    try {
      final request = await createRequest();
      final streamedResponse = await networkClient.send(request);
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
    } catch (error) {
      if (error is APIError) rethrow;
      throw const APIError(APIErrorType.invalidResponse);
    } finally {
      networkClient.close();
    }
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
      final data = fromJson(decodedJson);
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
  Future<void> performAsync() async {
    await performAsyncWithCookies();
  }

  Future<NetworkResponse<void>> performAsyncWithCookies() async {
    if (!await TargetRequest.isConnectedToInternet) {
      throw const APIError(APIErrorType.noNetwork);
    }

    final httpClient = http.Client();
    late final NetworkClient networkClient;
    networkClient = NetworkClient(
      httpClient,
      interceptors: [
        AuthInterceptor(
          isAuthorized: isAuthorized,
          refreshRequest: () async {
            await TokenRefreshRegistry.refreshToken();
            return createRequest();
          },
          retry: (req) => networkClient.send(req),
        ),
        LoggingInterceptor(),
      ],
    );

    try {
      final request = await createRequest();
      final streamedResponse = await networkClient.send(request);
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
      final responseData = await streamedResponse.stream.toBytes();
      final errorModel = await _tryDecodeError(responseData);
      throw APIError(APIErrorType.httpError,
          statusCode: statusCategory, errorModel: errorModel);
    } catch (error) {
      if (error is APIError) rethrow;
      if (error is UnsupportedError) rethrow;
      throw const APIError(APIErrorType.invalidResponse);
    } finally {
      networkClient.close();
    }
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
