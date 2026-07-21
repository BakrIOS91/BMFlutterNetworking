import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:bm_flutter_networking/src/network/core/inspector/network_inspector.dart';
import 'package:bm_flutter_networking/src/network/core/inspector/network_log_entry.dart';
import 'package:bm_flutter_networking/src/network/core/logger.dart';
import '../interceptor.dart';

/// Interceptor that handles logging of requests and responses, both to the
/// console (via [Logger]) and to the in-app [NetworkInspector] used by
/// [NetworkInspectorOverlay].
class LoggingInterceptor extends NetworkInterceptor {
  NetworkLogEntry? _entry;
  final Stopwatch _stopwatch = Stopwatch();

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

    _stopwatch.start();
    _entry = NetworkInspector.instance.logRequest(
      method: request.method,
      url: request.url,
      headers: request.headers,
      body: body is Uint8List ? body : null,
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

    _stopwatch.stop();
    NetworkInspector.instance.logResponse(
      entry: _entry,
      statusCode: response.statusCode,
      headers: response.headers,
      body: bytes,
      duration: _stopwatch.elapsed,
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

    _stopwatch.stop();
    NetworkInspector.instance.logError(
      entry: _entry,
      error: error,
      duration: _stopwatch.elapsed,
    );

    return null;
  }
}
