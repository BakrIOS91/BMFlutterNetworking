import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

class _TestTarget extends Target {
  final String _host;
  final String? _mainPath;
  final String? _apiPath;
  final String _scheme;
  final int? _port;

  _TestTarget({
    required String host,
    String? mainPath,
    String? apiPath,
    String scheme = 'https',
    int? port,
  })  : _host = host,
        _mainPath = mainPath,
        _apiPath = apiPath,
        _scheme = scheme,
        _port = port;

  @override
  String get kAppHost => _host;

  @override
  String? get kMainAPIPath => _mainPath;

  @override
  String? get kAppApiPath => _apiPath;

  @override
  String get kAppScheme => _scheme;

  @override
  int? get kAppPort => _port;
}

// Minimal target that uses all default implementations from Target
class _MinimalTarget extends Target {
  @override
  String get kAppHost => 'example.com';
  @override
  String get kAppScheme => 'https';
  // appEnvironment, kMainAPIPath, kAppApiPath, kAppPort all use Target defaults
}

void main() {
  group('Target default implementations', () {
    test('appEnvironment defaults to development', () {
      expect(_MinimalTarget().appEnvironment, AppEnvironment.development);
    });

    test('kMainAPIPath defaults to null', () {
      expect(_MinimalTarget().kMainAPIPath, isNull);
    });

    test('kAppApiPath defaults to null', () {
      expect(_MinimalTarget().kAppApiPath, isNull);
    });

    test('kAppPort defaults to null', () {
      expect(_MinimalTarget().kAppPort, isNull);
    });

    test('kBaseURL with no paths uses defaults', () {
      expect(_MinimalTarget().kBaseURL, 'https://example.com/');
    });
  });

  group('Target.sanitizedHost', () {
    test('removes leading and trailing slashes', () {
      final target = _TestTarget(host: '//example.com//');
      expect(target.sanitizedHost, 'example.com');
    });

    test('leaves clean host unchanged', () {
      final target = _TestTarget(host: 'example.com');
      expect(target.sanitizedHost, 'example.com');
    });

    test('removes only leading slash', () {
      final target = _TestTarget(host: '/example.com');
      expect(target.sanitizedHost, 'example.com');
    });

    test('removes only trailing slash', () {
      final target = _TestTarget(host: 'example.com/');
      expect(target.sanitizedHost, 'example.com');
    });
  });

  group('Target.kBaseURLComponents', () {
    test('base URL with no paths produces root path', () {
      final target = _TestTarget(host: 'example.com', scheme: 'https');
      final uri = target.kBaseURLComponents;
      expect(uri.scheme, 'https');
      expect(uri.host, 'example.com');
      expect(uri.path, '/');
    });

    test('base URL with mainAPIPath only', () {
      final target = _TestTarget(
        host: 'example.com',
        mainPath: 'api',
        scheme: 'https',
      );
      final uri = target.kBaseURLComponents;
      expect(uri.path, '/api/');
    });

    test('base URL with apiPath only', () {
      final target = _TestTarget(
        host: 'example.com',
        apiPath: 'v1',
        scheme: 'https',
      );
      final uri = target.kBaseURLComponents;
      expect(uri.path, '/v1/');
    });

    test('base URL with both mainAPIPath and apiPath', () {
      final target = _TestTarget(
        host: 'example.com',
        mainPath: 'api',
        apiPath: 'v2',
        scheme: 'https',
      );
      final uri = target.kBaseURLComponents;
      expect(uri.path, '/api/v2/');
    });

    test('strips slashes from path segments', () {
      final target = _TestTarget(
        host: 'example.com',
        mainPath: '/api/',
        apiPath: '/v1/',
        scheme: 'https',
      );
      final uri = target.kBaseURLComponents;
      expect(uri.path, '/api/v1/');
    });

    test('includes port when specified', () {
      final target = _TestTarget(
        host: 'example.com',
        scheme: 'http',
        port: 8080,
      );
      final uri = target.kBaseURLComponents;
      expect(uri.port, 8080);
    });

    test('empty mainAPIPath is ignored', () {
      final target = _TestTarget(
        host: 'example.com',
        mainPath: '',
        apiPath: 'v1',
        scheme: 'https',
      );
      final uri = target.kBaseURLComponents;
      expect(uri.path, '/v1/');
    });

    test('empty apiPath is ignored', () {
      final target = _TestTarget(
        host: 'example.com',
        mainPath: 'api',
        apiPath: '',
        scheme: 'https',
      );
      final uri = target.kBaseURLComponents;
      expect(uri.path, '/api/');
    });
  });

  group('Target.kBaseURL', () {
    test('returns string representation', () {
      final target = _TestTarget(host: 'example.com', scheme: 'https');
      expect(target.kBaseURL, 'https://example.com/');
    });

    test('includes port in URL string', () {
      final target = _TestTarget(
        host: 'api.example.com',
        mainPath: 'api',
        scheme: 'http',
        port: 3000,
      );
      expect(target.kBaseURL, 'http://api.example.com:3000/api/');
    });
  });
}
