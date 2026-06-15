import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:bm_flutter_networking/src/network/core/logger.dart';
import '../interceptor.dart';

/// Interceptor that handles logging of requests and responses.
class LoggingInterceptor extends NetworkInterceptor {
  @override
  FutureOr<http.BaseRequest> onRequest(http.BaseRequest request) {
    if (!Logger.isEnabled) return request;

    dynamic body;
    if (request is http.Request) {
      body = request.bodyBytes;
    }

    Logger.logRequest(
      method: request.method,
      url: request.url,
      headers: request.headers,
      body: body,
    );
    return request;
  }

  @override
  FutureOr<http.StreamedResponse> onResponse(
      http.BaseRequest request, http.StreamedResponse response) async {
    if (!Logger.isEnabled) return response;

    final bytes = await response.stream.toBytes();

    Logger.logResponse(
      method: request.method,
      url: request.url,
      statusCode: response.statusCode,
      responseData: bytes,
    );

    return http.StreamedResponse(
      Stream.value(bytes),
      response.statusCode,
      contentLength: response.contentLength,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  @override
  FutureOr<http.StreamedResponse?> onError(
      http.BaseRequest request, Object error) {
    if (!Logger.isEnabled) return null;

    Logger.logResponse(
      method: request.method,
      url: request.url,
      error: error,
    );
    return null;
  }
}
