import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:bm_flutter_networking/src/network/core/interceptors/logging_interceptor.dart';

http.Request _request({String method = 'GET'}) =>
    http.Request(method, Uri.parse('https://example.com/api'));

http.StreamedResponse _streamedResponse(int statusCode, {String body = ''}) {
  return http.StreamedResponse(
    Stream.value(body.codeUnits.map((c) => c).toList().cast<int>()),
    statusCode,
  );
}

void main() {
  tearDown(() {
    Logger.isEnabled = true;
  });

  group('LoggingInterceptor.onRequest', () {
    test('returns request unchanged when Logger disabled', () async {
      Logger.isEnabled = false;
      final interceptor = LoggingInterceptor();
      final req = _request();
      final result = await interceptor.onRequest(req);
      expect(result, same(req));
    });

    test('returns http.Request unchanged when Logger enabled', () async {
      Logger.isEnabled = true;
      final interceptor = LoggingInterceptor();
      final req = http.Request('POST', Uri.parse('https://example.com/api'));
      req.bodyBytes = [1, 2, 3];
      final result = await interceptor.onRequest(req);
      expect(result, same(req));
    });

    test('returns non-Request BaseRequest unchanged when Logger enabled', () async {
      Logger.isEnabled = true;
      final interceptor = LoggingInterceptor();
      final req = http.MultipartRequest('POST', Uri.parse('https://example.com/api'));
      final result = await interceptor.onRequest(req);
      expect(result, same(req));
    });
  });

  group('LoggingInterceptor.onResponse', () {
    test('returns response unchanged when Logger disabled', () async {
      Logger.isEnabled = false;
      final interceptor = LoggingInterceptor();
      final req = _request();
      final response = _streamedResponse(200, body: 'test');
      final result = await interceptor.onResponse(req, response);
      expect(result, same(response));
    });

    test('buffers and reconstructs response when Logger enabled', () async {
      Logger.isEnabled = true;
      final interceptor = LoggingInterceptor();
      final req = _request();
      final response = _streamedResponse(200, body: '{"id": 1}');
      final result = await interceptor.onResponse(req, response);
      // Original response is consumed; a new StreamedResponse is returned
      expect(result.statusCode, 200);
      final bytes = await result.stream.toBytes();
      expect(String.fromCharCodes(bytes), '{"id": 1}');
    });

    test('preserves response metadata when Logger enabled', () async {
      Logger.isEnabled = true;
      final interceptor = LoggingInterceptor();
      final req = _request();
      final response = http.StreamedResponse(
        Stream.value('data'.codeUnits.cast<int>().toList()),
        201,
        headers: {'x-custom': 'header-value'},
        reasonPhrase: 'Created',
      );
      final result = await interceptor.onResponse(req, response);
      expect(result.statusCode, 201);
      expect(result.headers['x-custom'], 'header-value');
      expect(result.reasonPhrase, 'Created');
    });
  });

  group('LoggingInterceptor.onError', () {
    test('returns null when Logger disabled', () async {
      Logger.isEnabled = false;
      final interceptor = LoggingInterceptor();
      final result = await interceptor.onError(_request(), Exception('error'));
      expect(result, isNull);
    });

    test('returns null when Logger enabled (does not recover)', () async {
      Logger.isEnabled = true;
      final interceptor = LoggingInterceptor();
      final result =
          await interceptor.onError(_request(), Exception('network error'));
      expect(result, isNull);
    });
  });
}
