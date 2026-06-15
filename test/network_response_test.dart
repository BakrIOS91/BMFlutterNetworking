import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

void main() {
  group('NetworkResponse', () {
    test('stores all fields correctly', () {
      final cookies = [BMCookie(name: 'session', value: 'abc123')];
      final response = NetworkResponse<String>(
        data: 'hello',
        statusCode: 200,
        headers: {'content-type': 'application/json'},
        rawSetCookieHeader: 'session=abc123',
        cookies: cookies,
      );
      expect(response.data, 'hello');
      expect(response.statusCode, 200);
      expect(response.headers['content-type'], 'application/json');
      expect(response.rawSetCookieHeader, 'session=abc123');
      expect(response.cookies, cookies);
    });

    test('cookieHeader returns formatted string when cookies present', () {
      final cookies = [
        BMCookie(name: 'session', value: 'abc'),
        BMCookie(name: 'user', value: '123'),
      ];
      final response = NetworkResponse<void>(
        data: null,
        statusCode: 200,
        headers: {},
        rawSetCookieHeader: null,
        cookies: cookies,
      );
      expect(response.cookieHeader, 'session=abc; user=123');
    });

    test('cookieHeader returns null when cookies are empty', () {
      final response = NetworkResponse<void>(
        data: null,
        statusCode: 200,
        headers: {},
        rawSetCookieHeader: null,
        cookies: const [],
      );
      expect(response.cookieHeader, isNull);
    });

    test('accepts void data', () {
      final response = NetworkResponse<void>(
        data: null,
        statusCode: 204,
        headers: {},
        rawSetCookieHeader: null,
        cookies: const [],
      );
      expect(response.statusCode, 204);
    });
  });

  group('parseSetCookieHeader', () {
    test('returns empty list for null input', () {
      expect(parseSetCookieHeader(null), isEmpty);
    });

    test('returns empty list for empty string', () {
      expect(parseSetCookieHeader(''), isEmpty);
    });

    test('returns empty list for whitespace-only string', () {
      expect(parseSetCookieHeader('   '), isEmpty);
    });

    test('parses a single simple cookie', () {
      final cookies = parseSetCookieHeader('session=abc123');
      expect(cookies.length, 1);
      expect(cookies[0].name, 'session');
      expect(cookies[0].value, 'abc123');
    });

    test('parses a cookie with attributes', () {
      final cookies = parseSetCookieHeader('session=abc123; Path=/; HttpOnly');
      expect(cookies.length, 1);
      expect(cookies[0].name, 'session');
      expect(cookies[0].value, 'abc123');
      expect(cookies[0].httpOnly, isTrue);
      expect(cookies[0].path, '/');
    });

    test('splits multiple cookies on comma', () {
      final cookies = parseSetCookieHeader('session=abc, token=xyz');
      expect(cookies.length, 2);
      expect(cookies[0].name, 'session');
      expect(cookies[1].name, 'token');
    });

    test('does not split on comma inside expires attribute', () {
      final cookies = parseSetCookieHeader(
          'session=abc; expires=Mon, 01 Jan 2030 00:00:00 GMT; Path=/, other=xyz');
      expect(cookies.length, 2);
      expect(cookies[0].name, 'session');
      expect(cookies[1].name, 'other');
    });

    test('parses or skips malformed cookie parts without throwing', () {
      expect(
        () => parseSetCookieHeader('valid=ok, !!!invalid!!!'),
        returnsNormally,
      );
      final cookies = parseSetCookieHeader('valid=ok, !!!invalid!!!');
      expect(cookies.first.name, 'valid');
    });
  });
}
