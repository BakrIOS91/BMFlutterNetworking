import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

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

class _Item {
  final String title;
  _Item(this.title);
}

class _ItemTarget extends ModelTargetType<_Item> {
  @override
  String get baseURL => 'https://api.example.com/';
  @override
  String get requestPath => 'items/1';
  @override
  HTTPMethod get requestMethod => HTTPMethod.get;
  @override
  Map<String, String> get headers => const {};
  @override
  Map<String, String> get authHeaders => const {};

  @override
  _Item fromJson(Map<String, dynamic> json) => _Item(json['title']);
}

class _VoidTarget extends SuccessTargetType {
  @override
  String get baseURL => 'https://api.example.com/';
  @override
  String get requestPath => 'actions/reset';
  @override
  HTTPMethod get requestMethod => HTTPMethod.post;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Logger.isEnabled = false;
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
  // ModelTargetType.performResult
  // -------------------------------------------------------------------------
  group('ModelTargetType.performResult', () {
    test('returns Success wrapping decoded model on 200', () async {
      _mockConnectivity(['wifi']);
      final target = _ItemTarget();

      final result = await http.runWithClient(
        () => target.performResult<_Item>(),
        () => MockClient(
          (_) async => http.Response(
            jsonEncode({'title': 'Hello'}),
            200,
          ),
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.value?.title, 'Hello');
    });

    test('returns Failure wrapping APIError on network error', () async {
      _mockConnectivity(['none']);
      final target = _ItemTarget();
      final result = await target.performResult<_Item>();

      expect(result.isFailure, isTrue);
      expect(result.error?.type, APIErrorType.noNetwork);
    });

    test('returns Failure wrapping APIError on 404', () async {
      _mockConnectivity(['wifi']);
      final target = _ItemTarget();

      final result = await http.runWithClient(
        () => target.performResult<_Item>(),
        () => MockClient((_) async => http.Response('Not Found', 404)),
      );

      expect(result.isFailure, isTrue);
      expect(result.error?.type, APIErrorType.httpError);
    });
  });

  // -------------------------------------------------------------------------
  // ModelTargetType.performResultWithCookies
  // -------------------------------------------------------------------------
  group('ModelTargetType.performResultWithCookies', () {
    test('returns Success wrapping NetworkResponse on 200', () async {
      _mockConnectivity(['wifi']);
      final target = _ItemTarget();

      final result = await http.runWithClient(
        () => target.performResultWithCookies<_Item>(),
        () => MockClient(
          (_) async => http.Response(
            jsonEncode({'title': 'World'}),
            200,
          ),
        ),
      );

      expect(result.isSuccess, isTrue);
      expect(result.value?.data.title, 'World');
      expect(result.value?.statusCode, 200);
    });

    test('returns Failure on network error', () async {
      _mockConnectivity(['none']);
      final target = _ItemTarget();
      final result = await target.performResultWithCookies<_Item>();

      expect(result.isFailure, isTrue);
      expect(result.error?.type, APIErrorType.noNetwork);
    });
  });

  // -------------------------------------------------------------------------
  // ModelTargetType.performDownloadResult
  // -------------------------------------------------------------------------
  group('ModelTargetType.performDownloadResult', () {
    test('returns Success wrapping DownloadedFile on 200', () async {
      _mockConnectivity(['wifi']);
      final target = _ItemTarget();

      final result = await http.runWithClient(
        () => target.performDownloadResult(),
        () => MockClient((_) async => http.Response('bytes', 200)),
      );

      expect(result.isSuccess, isTrue);
    });

    test('returns Failure on network error', () async {
      _mockConnectivity(['none']);
      final target = _ItemTarget();
      final result = await target.performDownloadResult();

      expect(result.isFailure, isTrue);
      expect(result.error?.type, APIErrorType.noNetwork);
    });

    test('returns Failure on 401', () async {
      _mockConnectivity(['wifi']);
      final target = _ItemTarget();

      final result = await http.runWithClient(
        () => target.performDownloadResult(),
        () => MockClient((_) async => http.Response('Unauthorized', 401)),
      );

      expect(result.isFailure, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // SuccessTargetType.performResult
  // -------------------------------------------------------------------------
  group('SuccessTargetType.performResult', () {
    test('returns Success<void> on 200', () async {
      _mockConnectivity(['wifi']);
      final target = _VoidTarget();

      final result = await http.runWithClient(
        () => target.performResult(),
        () => MockClient((_) async => http.Response('', 200)),
      );

      expect(result.isSuccess, isTrue);
    });

    test('returns Failure on network error', () async {
      _mockConnectivity(['none']);
      final target = _VoidTarget();
      final result = await target.performResult();

      expect(result.isFailure, isTrue);
      expect(result.error?.type, APIErrorType.noNetwork);
    });

    test('returns Failure on 500', () async {
      _mockConnectivity(['wifi']);
      final target = _VoidTarget();

      final result = await http.runWithClient(
        () => target.performResult(),
        () => MockClient((_) async => http.Response('', 500)),
      );

      expect(result.isFailure, isTrue);
    });
  });

  // -------------------------------------------------------------------------
  // SuccessTargetType.performResultWithCookies
  // -------------------------------------------------------------------------
  group('SuccessTargetType.performResultWithCookies', () {
    test('returns Success wrapping NetworkResponse on 200', () async {
      _mockConnectivity(['wifi']);
      final target = _VoidTarget();

      final result = await http.runWithClient(
        () => target.performResultWithCookies(),
        () => MockClient((_) async => http.Response('', 200)),
      );

      expect(result.isSuccess, isTrue);
      expect(result.value?.statusCode, 200);
    });

    test('returns Failure on network error', () async {
      _mockConnectivity(['none']);
      final target = _VoidTarget();
      final result = await target.performResultWithCookies();

      expect(result.isFailure, isTrue);
    });

    test('returns Failure on 422', () async {
      _mockConnectivity(['wifi']);
      final target = _VoidTarget();

      final result = await http.runWithClient(
        () => target.performResultWithCookies(),
        () => MockClient((_) async => http.Response('', 422)),
      );

      expect(result.isFailure, isTrue);
    });
  });
}
