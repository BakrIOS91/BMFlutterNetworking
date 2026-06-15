import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

void main() {
  group('BMCookie constructor', () {
    test('stores required fields', () {
      const cookie = BMCookie(name: 'session', value: 'abc123');
      expect(cookie.name, 'session');
      expect(cookie.value, 'abc123');
    });

    test('defaults optional flags to false/null', () {
      const cookie = BMCookie(name: 'x', value: 'y');
      expect(cookie.domain, isNull);
      expect(cookie.path, isNull);
      expect(cookie.httpOnly, isFalse);
      expect(cookie.secure, isFalse);
    });

    test('stores all fields when provided', () {
      const cookie = BMCookie(
        name: 'token',
        value: 'xyz',
        domain: 'example.com',
        path: '/api',
        httpOnly: true,
        secure: true,
      );
      expect(cookie.name, 'token');
      expect(cookie.value, 'xyz');
      expect(cookie.domain, 'example.com');
      expect(cookie.path, '/api');
      expect(cookie.httpOnly, isTrue);
      expect(cookie.secure, isTrue);
    });
  });

  group('BMCookie.fromSetCookieValue', () {
    test('parses simple name=value', () {
      final c = BMCookie.fromSetCookieValue('session=abc123');
      expect(c.name, 'session');
      expect(c.value, 'abc123');
    });

    test('parses value containing = sign', () {
      final c = BMCookie.fromSetCookieValue('token=a=b=c');
      expect(c.name, 'token');
      expect(c.value, 'a=b=c');
    });

    test('parses name only (no = sign)', () {
      final c = BMCookie.fromSetCookieValue('nocookievalue');
      expect(c.name, 'nocookievalue');
      expect(c.value, '');
    });

    test('parses Path attribute', () {
      final c = BMCookie.fromSetCookieValue('sid=1; Path=/app');
      expect(c.name, 'sid');
      expect(c.value, '1');
      expect(c.path, '/app');
    });

    test('parses Domain attribute', () {
      final c = BMCookie.fromSetCookieValue('sid=1; Domain=example.com');
      expect(c.domain, 'example.com');
    });

    test('parses HttpOnly flag (case-insensitive)', () {
      final c = BMCookie.fromSetCookieValue('sid=1; HttpOnly');
      expect(c.httpOnly, isTrue);
    });

    test('parses Secure flag (case-insensitive)', () {
      final c = BMCookie.fromSetCookieValue('sid=1; Secure');
      expect(c.secure, isTrue);
    });

    test('parses all attributes together', () {
      final c = BMCookie.fromSetCookieValue(
        'session=xyz; Path=/; Domain=example.com; HttpOnly; Secure',
      );
      expect(c.name, 'session');
      expect(c.value, 'xyz');
      expect(c.path, '/');
      expect(c.domain, 'example.com');
      expect(c.httpOnly, isTrue);
      expect(c.secure, isTrue);
    });

    test('trims whitespace around name and value', () {
      final c = BMCookie.fromSetCookieValue('  name  =  value  ');
      expect(c.name, 'name');
      expect(c.value, 'value');
    });

    test('ignores unknown attributes without throwing', () {
      expect(
        () => BMCookie.fromSetCookieValue('sid=1; SameSite=Lax; Max-Age=3600'),
        returnsNormally,
      );
    });
  });
}
