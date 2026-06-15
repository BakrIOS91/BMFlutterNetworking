import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:bm_flutter_networking/src/network/core/interceptor.dart';

// Minimal concrete interceptor with default behavior
class _NoopInterceptor extends NetworkInterceptor {}

// Interceptor that logs calls
class _TrackingInterceptor extends NetworkInterceptor {
  final String id;
  final List<String> log;

  _TrackingInterceptor(this.id, this.log);

  @override
  FutureOr<http.BaseRequest> onRequest(http.BaseRequest request) {
    log.add('$id.onRequest');
    return request;
  }

  @override
  FutureOr<http.StreamedResponse> onResponse(
      http.BaseRequest request, http.StreamedResponse response) {
    log.add('$id.onResponse');
    return response;
  }

  @override
  FutureOr<http.StreamedResponse?> onError(
      http.BaseRequest request, Object error) {
    log.add('$id.onError');
    return null;
  }
}

// Interceptor that recovers from errors
class _ErrorRecoveringInterceptor extends NetworkInterceptor {
  final http.StreamedResponse recoveredResponse;

  _ErrorRecoveringInterceptor(this.recoveredResponse);

  @override
  FutureOr<http.StreamedResponse?> onError(
      http.BaseRequest request, Object error) {
    return recoveredResponse;
  }
}

// Interceptor that adds a request header
class _HeaderAddingInterceptor extends NetworkInterceptor {
  @override
  FutureOr<http.BaseRequest> onRequest(http.BaseRequest request) {
    request.headers['X-Intercepted'] = 'true';
    return request;
  }
}

// Client that tracks when close() is called
class _TrackCloseClient extends http.BaseClient {
  bool closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(const Stream.empty(), 200);
  }

  @override
  void close() {
    closed = true;
  }
}

http.StreamedResponse _makeResponse(int statusCode, {String body = ''}) {
  return http.StreamedResponse(
    Stream.value(body.codeUnits.map((c) => c).toList().cast<int>()),
    statusCode,
  );
}

void main() {
  group('NetworkInterceptor default methods', () {
    late _NoopInterceptor interceptor;
    late http.Request request;

    setUp(() {
      interceptor = _NoopInterceptor();
      request = http.Request('GET', Uri.parse('https://example.com'));
    });

    test('onRequest returns request unchanged', () async {
      final result = await interceptor.onRequest(request);
      expect(result, same(request));
    });

    test('onResponse returns response unchanged', () async {
      final response = _makeResponse(200);
      final result = await interceptor.onResponse(request, response);
      expect(result, same(response));
    });

    test('onError returns null', () async {
      final result = await interceptor.onError(request, Exception('error'));
      expect(result, isNull);
    });
  });

  group('NetworkClient', () {
    late http.Request baseRequest;

    setUp(() {
      baseRequest = http.Request('GET', Uri.parse('https://example.com/'));
    });

    test('sends request through inner client', () async {
      final mockClient = MockClient((_) async => http.Response('ok', 200));
      final networkClient = NetworkClient(mockClient);
      final response = await networkClient.send(baseRequest);
      expect(response.statusCode, 200);
    });

    test('works with no interceptors', () async {
      final mockClient = MockClient((_) async => http.Response('', 204));
      final networkClient = NetworkClient(mockClient, interceptors: []);
      final response = await networkClient.send(baseRequest);
      expect(response.statusCode, 204);
    });

    test('applies request interceptors in forward order', () async {
      final log = <String>[];
      final mockClient = MockClient((_) async => http.Response('', 200));
      final networkClient = NetworkClient(
        mockClient,
        interceptors: [
          _TrackingInterceptor('A', log),
          _TrackingInterceptor('B', log),
        ],
      );
      await networkClient.send(baseRequest);
      expect(log[0], 'A.onRequest');
      expect(log[1], 'B.onRequest');
    });

    test('applies response interceptors in reverse order', () async {
      final log = <String>[];
      final mockClient = MockClient((_) async => http.Response('', 200));
      final networkClient = NetworkClient(
        mockClient,
        interceptors: [
          _TrackingInterceptor('A', log),
          _TrackingInterceptor('B', log),
        ],
      );
      await networkClient.send(baseRequest);
      // Response is processed in reverse: B first, then A
      expect(log[2], 'B.onResponse');
      expect(log[3], 'A.onResponse');
    });

    test('rethrows when no interceptor recovers from error', () async {
      final failingClient =
          MockClient((_) async => throw Exception('network failure'));
      final networkClient = NetworkClient(failingClient);
      await expectLater(networkClient.send(baseRequest), throwsException);
    });

    test('calls onError interceptors when inner client throws', () async {
      final log = <String>[];
      final failingClient =
          MockClient((_) async => throw Exception('failure'));
      final networkClient = NetworkClient(
        failingClient,
        interceptors: [_TrackingInterceptor('A', log)],
      );
      try {
        await networkClient.send(baseRequest);
      } catch (_) {}
      expect(log, contains('A.onError'));
    });

    test('returns recovered response from error interceptor', () async {
      final recovered = _makeResponse(200, body: 'recovered');
      final failingClient =
          MockClient((_) async => throw Exception('failure'));
      final networkClient = NetworkClient(
        failingClient,
        interceptors: [_ErrorRecoveringInterceptor(recovered)],
      );
      final response = await networkClient.send(baseRequest);
      expect(response.statusCode, 200);
    });

    test('header-adding interceptor modifies the sent request', () async {
      String? capturedHeader;
      final mockClient = MockClient((request) async {
        capturedHeader = request.headers['X-Intercepted'];
        return http.Response('', 200);
      });
      final networkClient = NetworkClient(
        mockClient,
        interceptors: [_HeaderAddingInterceptor()],
      );
      await networkClient.send(baseRequest);
      expect(capturedHeader, 'true');
    });

    test('close() delegates to inner client', () {
      final trackClient = _TrackCloseClient();
      final networkClient = NetworkClient(trackClient);
      networkClient.close();
      expect(trackClient.closed, isTrue);
    });
  });
}
