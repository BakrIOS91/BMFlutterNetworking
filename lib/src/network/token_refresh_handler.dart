/// Token Refresh Handler for BMFlutter Networking Layer
///
/// Provides automatic token refresh when a 401 Unauthorized response is
/// received on an authorized request. A Completer-based mutex ensures that
/// if multiple requests receive a 401 simultaneously, only ONE refresh call
/// is made — all concurrent waiters share the same Future result.
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:bm_flutter_networking/src/helpers/api_error.dart';
import 'package:bm_flutter_networking/src/helpers/enums.dart';

/// Abstract interface that the host app implements to provide token-refresh logic.
abstract class TokenRefreshHandler {
  Future<bool> refreshToken();
}

/// Global registry for [TokenRefreshHandler] with a Completer-based mutex.
class TokenRefreshRegistry {
  TokenRefreshRegistry._();

  @visibleForTesting
  static TokenRefreshRegistry createForTesting() => TokenRefreshRegistry._();

  static TokenRefreshHandler? _handler;
  static Completer<void>? _refreshCompleter;

  static void register(TokenRefreshHandler handler) {
    _handler = handler;
  }

  static void clear() {
    _handler = null;
    _refreshCompleter = null;
  }

  static Future<void> refreshToken() async {
    if (_handler == null) {
      throw const APIError(APIErrorType.httpError,
          statusCode: HTTPStatusCode.notAuthorize);
    }

    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<void>();
    try {
      await _doRefresh();
      _refreshCompleter!.complete();
    } catch (e) {
      _refreshCompleter!.completeError(e);
      rethrow;
    } finally {
      _refreshCompleter = null;
    }
  }

  static Future<void> _doRefresh() async {
    final success = await _handler?.refreshToken();
    if (success != true) {
      throw const APIError(APIErrorType.httpError,
          statusCode: HTTPStatusCode.notAuthorize);
    }
  }
}
