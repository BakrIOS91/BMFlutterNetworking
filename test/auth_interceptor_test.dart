import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:bm_flutter_networking/src/network/core/interceptors/auth_interceptor.dart';

http.StreamedResponse _response(int statusCode) {
  return http.StreamedResponse(const Stream.empty(), statusCode);
}

http.Request _request() =>
    http.Request('GET', Uri.parse('https://example.com/'));

void main() {
  group('AuthInterceptor.onResponse', () {
    test('passes non-401 response through unchanged', () async {
      final interceptor = AuthInterceptor(
        isAuthorized: true,
        refreshRequest: () async => _request(),
        retry: (_) async => _response(200),
      );
      final response = _response(200);
      final result = await interceptor.onResponse(_request(), response);
      expect(result.statusCode, 200);
      expect(result, same(response));
    });

    test('passes 401 through when isAuthorized is false', () async {
      final interceptor = AuthInterceptor(
        isAuthorized: false,
        refreshRequest: () async => _request(),
        retry: (_) async => _response(200),
      );
      final response = _response(401);
      final result = await interceptor.onResponse(_request(), response);
      expect(result.statusCode, 401);
      expect(result, same(response));
    });

    test('triggers token refresh on 401 when authorized', () async {
      bool refreshCalled = false;
      bool retryCalled = false;

      final interceptor = AuthInterceptor(
        isAuthorized: true,
        refreshRequest: () async {
          refreshCalled = true;
          return _request();
        },
        retry: (_) async {
          retryCalled = true;
          return _response(200);
        },
      );

      await interceptor.onResponse(_request(), _response(401));
      expect(refreshCalled, isTrue);
      expect(retryCalled, isTrue);
    });

    test('returns retried response after token refresh', () async {
      final interceptor = AuthInterceptor(
        isAuthorized: true,
        refreshRequest: () async => _request(),
        retry: (_) async => _response(200),
      );
      final result = await interceptor.onResponse(_request(), _response(401));
      expect(result.statusCode, 200);
    });

    test('returns original response when refresh throws', () async {
      final interceptor = AuthInterceptor(
        isAuthorized: true,
        refreshRequest: () async => throw Exception('refresh failed'),
        retry: (_) async => _response(200),
      );
      final original = _response(401);
      final result = await interceptor.onResponse(_request(), original);
      expect(result.statusCode, 401);
      expect(result, same(original));
    });

    test('does not retry when already retrying (prevents infinite loop)', () async {
      int retryCount = 0;

      late AuthInterceptor interceptor;
      interceptor = AuthInterceptor(
        isAuthorized: true,
        refreshRequest: () async => _request(),
        retry: (_) async {
          retryCount++;
          // Simulate a second 401 - interceptor should not loop
          return _response(401);
        },
      );

      await interceptor.onResponse(_request(), _response(401));
      // Retry was called exactly once
      expect(retryCount, 1);
    });

    test('passes 403 response through unchanged', () async {
      final interceptor = AuthInterceptor(
        isAuthorized: true,
        refreshRequest: () async => _request(),
        retry: (_) async => _response(200),
      );
      final response = _response(403);
      final result = await interceptor.onResponse(_request(), response);
      expect(result, same(response));
    });

    test('passes 500 response through unchanged', () async {
      final interceptor = AuthInterceptor(
        isAuthorized: true,
        refreshRequest: () async => _request(),
        retry: (_) async => _response(200),
      );
      final response = _response(500);
      final result = await interceptor.onResponse(_request(), response);
      expect(result, same(response));
    });
  });
}
