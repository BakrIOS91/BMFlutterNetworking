import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

// Connectivity channel constants
const _connectivityChannel =
    MethodChannel('dev.fluttercommunity.plus/connectivity');

void _mockConnectivity(List<String> results) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(_connectivityChannel,
          (MethodCall call) async {
    if (call.method == 'check') return results;
    return null;
  });
}

// Simple test model
class _User {
  final int id;
  final String name;
  _User({required this.id, required this.name});
}

// ModelTargetType for _User
class _UserTarget extends ModelTargetType<_User> {
  final String _base;
  final String _path;
  final HTTPMethod _method;
  final bool _authorized;
  final RequestTask? _task;

  _UserTarget({
    String base = 'https://api.example.com/',
    String path = 'users/1',
    HTTPMethod method = HTTPMethod.get,
    bool authorized = false,
    RequestTask? task,
  })  : _base = base,
        _path = path,
        _method = method,
        _authorized = authorized,
        _task = task;

  @override
  String get baseURL => _base;
  @override
  String get requestPath => _path;
  @override
  HTTPMethod get requestMethod => _method;
  @override
  bool get isAuthorized => _authorized;
  @override
  RequestTask get requestTask => _task ?? RequestTask.plain();
  @override
  Map<String, String> get headers => const {};
  @override
  Map<String, String> get authHeaders => const {};

  @override
  _User fromJson(Map<String, dynamic> json) =>
      _User(id: json['id'], name: json['name']);
}

// SuccessTargetType for void requests
class _PingTarget extends SuccessTargetType {
  @override
  String get baseURL => 'https://api.example.com/';
  @override
  String get requestPath => 'ping';
  @override
  HTTPMethod get requestMethod => HTTPMethod.get;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Logger.isEnabled = false; // Suppress logs in tests
    APIErrorResponseRegistry.clear();
    TokenRefreshRegistry.clear();
  });

  tearDown(() {
    Logger.isEnabled = true;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_connectivityChannel, null);
    APIErrorResponseRegistry.clear();
    TokenRefreshRegistry.clear();
  });

  // -------------------------------------------------------------------------
  // ModelTargetType.performAsync
  // -------------------------------------------------------------------------
  group('ModelTargetType.performAsync', () {
    test('throws APIError.noNetwork when not connected', () async {
      _mockConnectivity(['none']);
      final target = _UserTarget();
      await expectLater(
        target.performAsync<_User>(),
        throwsA(isA<APIError>().having(
          (e) => e.type,
          'type',
          APIErrorType.noNetwork,
        )),
      );
    });

    test('returns decoded model on 200 response', () async {
      _mockConnectivity(['wifi']);
      final responseBody = jsonEncode({'id': 1, 'name': 'Alice'});
      final target = _UserTarget();

      final user = await http.runWithClient(
        () => target.performAsync<_User>(),
        () => MockClient(
          (_) async => http.Response(responseBody, 200,
              headers: {'content-type': 'application/json'}),
        ),
      );

      expect(user.id, 1);
      expect(user.name, 'Alice');
    });

    test('throws APIError.httpError on 404 response', () async {
      _mockConnectivity(['wifi']);
      final target = _UserTarget();

      await expectLater(
        http.runWithClient(
          () => target.performAsync<_User>(),
          () => MockClient((_) async => http.Response('Not Found', 404)),
        ),
        throwsA(isA<APIError>().having(
          (e) => e.type,
          'type',
          APIErrorType.httpError,
        )),
      );
    });

    test('throws APIError.httpError on 500 response', () async {
      _mockConnectivity(['wifi']);
      final target = _UserTarget();

      await expectLater(
        http.runWithClient(
          () => target.performAsync<_User>(),
          () => MockClient((_) async => http.Response('Server Error', 500)),
        ),
        throwsA(isA<APIError>().having(
          (e) => e.type,
          'type',
          APIErrorType.httpError,
        )),
      );
    });

    test('throws APIError.dataConversionFailed when response is not valid JSON model', () async {
      _mockConnectivity(['wifi']);
      final target = _UserTarget();

      await expectLater(
        http.runWithClient(
          // Returns 200 but with malformed JSON for the model
          () => target.performAsync<_User>(),
          () => MockClient(
            (_) async =>
                http.Response('{"wrong_field": "value"}', 200),
          ),
        ),
        throwsA(isA<APIError>().having(
          (e) => e.type,
          'type',
          APIErrorType.dataConversionFailed,
        )),
      );
    });

    test('includes errorModel from registry on error response', () async {
      _mockConnectivity(['wifi']);
      APIErrorResponseRegistry.register(_TestErrorMapper());

      final target = _UserTarget();
      late APIError captured;

      try {
        await http.runWithClient(
          () => target.performAsync<_User>(),
          () => MockClient(
            (_) async => http.Response(
              jsonEncode({'error': 'not found'}),
              404,
              headers: {'content-type': 'application/json'},
            ),
          ),
        );
      } on APIError catch (e) {
        captured = e;
      }

      expect(captured.errorModel, isNotNull);
    });

    test('retries after token refresh on 401 for authorized target', () async {
      _mockConnectivity(['wifi']);
      TokenRefreshRegistry.register(_SuccessTokenRefreshHandler());
      int callCount = 0;
      final target = _UserTarget(authorized: true);

      final user = await http.runWithClient(
        () => target.performAsync<_User>(),
        () => MockClient((request) async {
          callCount++;
          if (callCount == 1) return http.Response('', 401);
          return http.Response(
            jsonEncode({'id': 1, 'name': 'Alice'}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      expect(user.name, 'Alice');
      expect(callCount, 2);
    });
  });

  // -------------------------------------------------------------------------
  // ModelTargetType.performAsyncWithCookies
  // -------------------------------------------------------------------------
  group('ModelTargetType.performAsyncWithCookies', () {
    test('returns NetworkResponse with cookies', () async {
      _mockConnectivity(['wifi']);
      final responseBody = jsonEncode({'id': 2, 'name': 'Bob'});
      final target = _UserTarget();

      final response = await http.runWithClient(
        () => target.performAsyncWithCookies<_User>(),
        () => MockClient(
          (_) async => http.Response(
            responseBody,
            200,
            headers: {
              'content-type': 'application/json',
              'set-cookie': 'session=abc123',
            },
          ),
        ),
      );

      expect(response.data.name, 'Bob');
      expect(response.statusCode, 200);
      expect(response.rawSetCookieHeader, 'session=abc123');
    });

    test('returns NetworkResponse with empty cookies when no Set-Cookie header', () async {
      _mockConnectivity(['wifi']);
      final target = _UserTarget();

      final response = await http.runWithClient(
        () => target.performAsyncWithCookies<_User>(),
        () => MockClient(
          (_) async => http.Response(
            jsonEncode({'id': 3, 'name': 'Charlie'}),
            200,
          ),
        ),
      );

      expect(response.cookies, isEmpty);
      expect(response.rawSetCookieHeader, isNull);
    });
  });

  // -------------------------------------------------------------------------
  // ModelTargetType.performDownload
  // -------------------------------------------------------------------------
  group('ModelTargetType.performDownload', () {
    test('throws APIError.noNetwork when not connected', () async {
      _mockConnectivity(['none']);
      final target = _UserTarget();
      await expectLater(
        target.performDownload(),
        throwsA(isA<APIError>().having(
          (e) => e.type,
          'type',
          APIErrorType.noNetwork,
        )),
      );
    });

    test('downloads file and returns DownloadedFile on success', () async {
      _mockConnectivity(['wifi']);
      final target = _UserTarget(path: 'files/report.pdf');

      final downloaded = await http.runWithClient(
        () => target.performDownload(),
        () => MockClient(
          (_) async => http.Response('PDF content', 200),
        ),
      );

      expect(downloaded, isNotNull);
      expect(downloaded!.downloadedUrl, isNotNull);
    });

    test('throws APIError.httpError on 401 during download', () async {
      _mockConnectivity(['wifi']);
      final target = _UserTarget();

      await expectLater(
        http.runWithClient(
          () => target.performDownload(),
          () => MockClient((_) async => http.Response('Unauthorized', 401)),
        ),
        throwsA(isA<APIError>().having(
          (e) => e.type,
          'type',
          APIErrorType.httpError,
        )),
      );
    });

    test('throws APIError.httpError on non-success status code', () async {
      _mockConnectivity(['wifi']);
      final target = _UserTarget();

      await expectLater(
        http.runWithClient(
          () => target.performDownload(),
          () => MockClient((_) async => http.Response('Error', 500)),
        ),
        throwsA(isA<APIError>()),
      );
    });

    test('uses unique filename when useUniqueFilename is true', () async {
      _mockConnectivity(['wifi']);
      final target = _UniqueFilenameTarget();

      final downloaded = await http.runWithClient(
        () => target.performDownload(),
        () => MockClient((_) async => http.Response('content', 200)),
      );

      expect(downloaded, isNotNull);
    });

    test('retries download after token refresh on 401 for authorized target', () async {
      _mockConnectivity(['wifi']);
      TokenRefreshRegistry.register(_SuccessTokenRefreshHandler());
      int callCount = 0;
      final target = _UserTarget(authorized: true, path: 'files/report.pdf');

      final downloaded = await http.runWithClient(
        () => target.performDownload(),
        () => MockClient((request) async {
          callCount++;
          if (callCount == 1) return http.Response('', 401);
          return http.Response('PDF content', 200);
        }),
      );

      expect(downloaded, isNotNull);
      expect(callCount, 2);
    });
  });

  // -------------------------------------------------------------------------
  // SuccessTargetType.performAsync
  // -------------------------------------------------------------------------
  group('SuccessTargetType.performAsync', () {
    test('throws APIError.noNetwork when not connected', () async {
      _mockConnectivity(['none']);
      final target = _PingTarget();
      await expectLater(
        target.performAsync(),
        throwsA(isA<APIError>().having(
          (e) => e.type,
          'type',
          APIErrorType.noNetwork,
        )),
      );
    });

    test('completes without error on 200 response', () async {
      _mockConnectivity(['wifi']);
      final target = _PingTarget();

      await expectLater(
        http.runWithClient(
          () => target.performAsync(),
          () => MockClient((_) async => http.Response('', 200)),
        ),
        completes,
      );
    });

    test('throws APIError.httpError on 422 response', () async {
      _mockConnectivity(['wifi']);
      final target = _PingTarget();

      await expectLater(
        http.runWithClient(
          () => target.performAsync(),
          () => MockClient((_) async => http.Response('error', 422)),
        ),
        throwsA(isA<APIError>().having(
          (e) => e.type,
          'type',
          APIErrorType.httpError,
        )),
      );
    });
  });

  // -------------------------------------------------------------------------
  // SuccessTargetType.performAsyncWithCookies
  // -------------------------------------------------------------------------
  group('SuccessTargetType.performAsyncWithCookies', () {
    test('returns NetworkResponse<void> on 200', () async {
      _mockConnectivity(['wifi']);
      final target = _PingTarget();

      final response = await http.runWithClient(
        () => target.performAsyncWithCookies(),
        () => MockClient(
          (_) async => http.Response(
            '',
            200,
            headers: {'set-cookie': 'session=token123'},
          ),
        ),
      );

      expect(response.statusCode, 200);
      expect(response.rawSetCookieHeader, 'session=token123');
    });

    test('throws on HTTP error', () async {
      _mockConnectivity(['wifi']);
      final target = _PingTarget();

      await expectLater(
        http.runWithClient(
          () => target.performAsyncWithCookies(),
          () => MockClient((_) async => http.Response('', 500)),
        ),
        throwsA(isA<APIError>()),
      );
    });

    test('retries after token refresh on 401 for authorized target', () async {
      _mockConnectivity(['wifi']);
      TokenRefreshRegistry.register(_SuccessTokenRefreshHandler());
      int callCount = 0;
      final target = _AuthPingTarget();

      final response = await http.runWithClient(
        () => target.performAsyncWithCookies(),
        () => MockClient((request) async {
          callCount++;
          if (callCount == 1) return http.Response('', 401);
          return http.Response('', 200);
        }),
      );

      expect(response.statusCode, 200);
      expect(callCount, 2);
    });
  });
}

class _AuthPingTarget extends SuccessTargetType {
  @override
  String get baseURL => 'https://api.example.com/';
  @override
  String get requestPath => 'ping';
  @override
  HTTPMethod get requestMethod => HTTPMethod.get;
  @override
  bool get isAuthorized => true;
}

class _SuccessTokenRefreshHandler extends TokenRefreshHandler {
  @override
  Future<bool> refreshToken() async => true;
}

class _TestErrorMapper extends APIErrorResponseMapper {
  @override
  dynamic decode(dynamic json) {
    if (json is Map) return json['error'];
    return null;
  }
}

class _UniqueFilenameTarget extends ModelTargetType<Map<String, dynamic>> {
  @override
  String get baseURL => 'https://cdn.example.com/';
  @override
  String get requestPath => 'files/document.pdf';
  @override
  HTTPMethod get requestMethod => HTTPMethod.get;
  @override
  bool get useUniqueFilename => true;
  @override
  Map<String, String> get headers => const {};
  @override
  Map<String, String> get authHeaders => const {};

  @override
  Map<String, dynamic> fromJson(Map<String, dynamic> json) => json;
}
