import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

class _SuccessHandler extends TokenRefreshHandler {
  int callCount = 0;
  @override
  Future<bool> refreshToken() async {
    callCount++;
    return true;
  }
}

class _FailureHandler extends TokenRefreshHandler {
  @override
  Future<bool> refreshToken() async => false;
}

class _ThrowingHandler extends TokenRefreshHandler {
  @override
  Future<bool> refreshToken() async => throw Exception('refresh failed');
}

class _SlowSuccessHandler extends TokenRefreshHandler {
  int callCount = 0;
  final Completer<void> _gate = Completer<void>();

  void complete() => _gate.complete();

  @override
  Future<bool> refreshToken() async {
    callCount++;
    await _gate.future;
    return true;
  }
}

void main() {
  tearDown(() {
    TokenRefreshRegistry.clear();
  });

  group('TokenRefreshRegistry', () {
    test('createForTesting returns an instance', () {
      expect(TokenRefreshRegistry.createForTesting(), isA<TokenRefreshRegistry>());
    });

    test('throws APIError when no handler registered', () async {
      await expectLater(
        TokenRefreshRegistry.refreshToken(),
        throwsA(isA<APIError>().having(
          (e) => e.type,
          'type',
          APIErrorType.httpError,
        )),
      );
    });

    test('successful refresh completes without error', () async {
      TokenRefreshRegistry.register(_SuccessHandler());
      await expectLater(TokenRefreshRegistry.refreshToken(), completes);
    });

    test('handler returning false throws APIError', () async {
      // The registry completes an internal Completer with error for concurrency
      // coordination; we use runZonedGuarded to suppress that unhandled future
      // error while still capturing the rethrown exception.
      TokenRefreshRegistry.register(_FailureHandler());
      Object? thrown;
      await runZonedGuarded(
        () async {
          try {
            await TokenRefreshRegistry.refreshToken();
          } catch (e) {
            thrown = e;
          }
        },
        (_, __) {}, // suppress unhandled completer errors
      );
      expect(thrown, isA<APIError>());
      expect(
        (thrown as APIError).statusCode,
        HTTPStatusCode.notAuthorize,
      );
    });

    test('handler throwing rethrows exception', () async {
      TokenRefreshRegistry.register(_ThrowingHandler());
      Object? thrown;
      await runZonedGuarded(
        () async {
          try {
            await TokenRefreshRegistry.refreshToken();
          } catch (e) {
            thrown = e;
          }
        },
        (_, __) {}, // suppress unhandled completer errors
      );
      expect(thrown, isA<Exception>());
    });

    test('clear removes registered handler', () async {
      TokenRefreshRegistry.register(_SuccessHandler());
      TokenRefreshRegistry.clear();
      await expectLater(
        TokenRefreshRegistry.refreshToken(),
        throwsA(isA<APIError>()),
      );
    });

    test('concurrent refreshes share a single handler call', () async {
      final handler = _SlowSuccessHandler();
      TokenRefreshRegistry.register(handler);

      // Start two concurrent refreshes
      final f1 = TokenRefreshRegistry.refreshToken();
      final f2 = TokenRefreshRegistry.refreshToken();

      // Allow the handler to complete
      handler.complete();

      await Future.wait([f1, f2]);
      // Only one actual refresh call should have been made
      expect(handler.callCount, 1);
    });
  });
}
