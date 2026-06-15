import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

void main() {
  setUp(() {
    Logger.isEnabled = true;
  });

  tearDown(() {
    // Reset to default (kDebugMode) after each test
    Logger.isEnabled = true;
  });

  group('Logger.isEnabled', () {
    test('can be set to false', () {
      Logger.isEnabled = false;
      expect(Logger.isEnabled, isFalse);
    });

    test('can be set to true', () {
      Logger.isEnabled = true;
      expect(Logger.isEnabled, isTrue);
    });
  });

  group('Logger.logRequest - when disabled', () {
    test('returns without logging when isEnabled is false', () {
      Logger.isEnabled = false;
      // Should not throw
      expect(() => Logger.logRequest(
        method: 'GET',
        url: Uri.parse('https://example.com/api'),
      ), returnsNormally);
    });
  });

  group('Logger.logRequest - when enabled', () {
    test('logs plain request without headers or body', () {
      expect(() => Logger.logRequest(
        method: 'GET',
        url: Uri.parse('https://example.com/api'),
      ), returnsNormally);
    });

    test('logs request with headers', () {
      expect(() => Logger.logRequest(
        method: 'POST',
        url: Uri.parse('https://example.com/api'),
        headers: {'Authorization': 'Bearer token', 'Accept': 'application/json'},
      ), returnsNormally);
    });

    test('logs request with parameters', () {
      expect(() => Logger.logRequest(
        method: 'GET',
        url: Uri.parse('https://example.com/api'),
        parameters: {'page': 1, 'limit': 20},
      ), returnsNormally);
    });

    test('logs request with JSON string body', () {
      expect(() => Logger.logRequest(
        method: 'POST',
        url: Uri.parse('https://example.com/api'),
        body: '{"name": "Alice"}',
      ), returnsNormally);
    });

    test('logs request with non-JSON string body', () {
      expect(() => Logger.logRequest(
        method: 'POST',
        url: Uri.parse('https://example.com/api'),
        body: 'plain text body',
      ), returnsNormally);
    });

    test('logs request with JSON array string body', () {
      expect(() => Logger.logRequest(
        method: 'POST',
        url: Uri.parse('https://example.com/api'),
        body: '[1, 2, 3]',
      ), returnsNormally);
    });

    test('logs request with Uint8List body (valid JSON bytes)', () {
      final bytes = Uint8List.fromList('{"key":"value"}'.codeUnits);
      expect(() => Logger.logRequest(
        method: 'POST',
        url: Uri.parse('https://example.com/api'),
        body: bytes,
      ), returnsNormally);
    });

    test('logs request with Uint8List body (non-JSON bytes)', () {
      final bytes = Uint8List.fromList([0xFF, 0xFE, 0x00]);
      expect(() => Logger.logRequest(
        method: 'POST',
        url: Uri.parse('https://example.com/api'),
        body: bytes,
      ), returnsNormally);
    });

    test('logs request with Map body', () {
      expect(() => Logger.logRequest(
        method: 'POST',
        url: Uri.parse('https://example.com/api'),
        body: {'name': 'Alice', 'age': 30},
      ), returnsNormally);
    });

    test('logs request with List body', () {
      expect(() => Logger.logRequest(
        method: 'POST',
        url: Uri.parse('https://example.com/api'),
        body: [1, 2, 3],
      ), returnsNormally);
    });

    test('logs request with other body type (int)', () {
      expect(() => Logger.logRequest(
        method: 'POST',
        url: Uri.parse('https://example.com/api'),
        body: 12345,
      ), returnsNormally);
    });

    test('logs request with empty headers map', () {
      expect(() => Logger.logRequest(
        method: 'GET',
        url: Uri.parse('https://example.com/api'),
        headers: {},
      ), returnsNormally);
    });

    test('logs request with empty parameters map', () {
      expect(() => Logger.logRequest(
        method: 'GET',
        url: Uri.parse('https://example.com/api'),
        parameters: {},
      ), returnsNormally);
    });

    test('logs request with parameters containing non-serializable value', () {
      // Triggers the catch branch in _prettyPrintJson (JsonEncoder throws)
      expect(() => Logger.logRequest(
        method: 'GET',
        url: Uri.parse('https://example.com/api'),
        parameters: {'obj': Object()},
      ), returnsNormally);
    });
  });

  group('Logger.logResponse - when disabled', () {
    test('returns without logging when isEnabled is false', () {
      Logger.isEnabled = false;
      expect(() => Logger.logResponse(
        method: 'GET',
        url: Uri.parse('https://example.com/api'),
        statusCode: 200,
      ), returnsNormally);
    });
  });

  group('Logger.logResponse - when enabled', () {
    test('logs success response (2xx)', () {
      expect(() => Logger.logResponse(
        method: 'GET',
        url: Uri.parse('https://example.com/api'),
        statusCode: 200,
      ), returnsNormally);
    });

    test('logs error response (4xx)', () {
      expect(() => Logger.logResponse(
        method: 'POST',
        url: Uri.parse('https://example.com/api'),
        statusCode: 422,
      ), returnsNormally);
    });

    test('logs response with JSON response data', () {
      final data = Uint8List.fromList('{"id": 1}'.codeUnits);
      expect(() => Logger.logResponse(
        method: 'GET',
        url: Uri.parse('https://example.com/api'),
        statusCode: 200,
        responseData: data,
      ), returnsNormally);
    });

    test('logs response with non-JSON response data', () {
      final data = Uint8List.fromList([0xFF, 0xFE]);
      expect(() => Logger.logResponse(
        method: 'GET',
        url: Uri.parse('https://example.com/api'),
        statusCode: 200,
        responseData: data,
      ), returnsNormally);
    });

    test('logs response with empty response data', () {
      expect(() => Logger.logResponse(
        method: 'GET',
        url: Uri.parse('https://example.com/api'),
        statusCode: 204,
        responseData: Uint8List(0),
      ), returnsNormally);
    });

    test('logs response with error object', () {
      expect(() => Logger.logResponse(
        method: 'GET',
        url: Uri.parse('https://example.com/api'),
        error: Exception('connection refused'),
      ), returnsNormally);
    });

    test('logs response with no status code', () {
      expect(() => Logger.logResponse(
        method: 'GET',
        url: Uri.parse('https://example.com/api'),
      ), returnsNormally);
    });
  });
}
