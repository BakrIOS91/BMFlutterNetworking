import 'dart:async';
import 'package:http/http.dart' as http;

/// Interface for network interceptors.
abstract class NetworkInterceptor {
  FutureOr<http.BaseRequest> onRequest(http.BaseRequest request) => request;

  FutureOr<http.StreamedResponse> onResponse(
          http.BaseRequest request, http.StreamedResponse response) =>
      response;

  FutureOr<http.StreamedResponse?> onError(
          http.BaseRequest request, Object error) =>
      null;
}

/// A client that supports interceptors.
class NetworkClient {
  final http.Client _inner;
  final List<NetworkInterceptor> interceptors;

  NetworkClient(this._inner, {this.interceptors = const []});

  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    http.BaseRequest currentRequest = request;

    for (var interceptor in interceptors) {
      currentRequest = await interceptor.onRequest(currentRequest);
    }

    try {
      http.StreamedResponse response = await _inner.send(currentRequest);

      for (var interceptor in interceptors.reversed) {
        response = await interceptor.onResponse(currentRequest, response);
      }

      return response;
    } catch (error) {
      for (var interceptor in interceptors.reversed) {
        final recoveredResponse =
            await interceptor.onError(currentRequest, error);
        if (recoveredResponse != null) {
          return recoveredResponse;
        }
      }
      rethrow;
    }
  }

  void close() => _inner.close();
}
