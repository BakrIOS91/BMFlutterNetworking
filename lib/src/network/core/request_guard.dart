import 'dart:async';

import 'package:bm_flutter_networking/src/helpers/api_error.dart';
import 'package:flutter/foundation.dart';

import 'cancel_token.dart';
import 'network_monitor.dart';

/// Watches one in-flight request and aborts it when the caller cancels or the
/// device goes offline, instead of waiting for the timeout.
///
/// A dropped request that changes state (any non-GET method) completes with
/// [APIErrorType.connectionLostDuringRequest] because the server may already
/// have processed it; such requests are never retried automatically.
/// Dropped reads complete with [APIErrorType.noNetwork].
class RequestGuard {
  RequestGuard({
    required this.isMutating,
    this.cancelToken,
    Stream<bool>? connectivity,
    required this.onAbort,
  }) : _connectivity = connectivity ?? connectivityProvider();

  /// Source of connectivity changes (true = online). Replaced in tests.
  @visibleForTesting
  static Stream<bool> Function() connectivityProvider =
      () => NetworkMonitor.onConnectivityChanged;

  /// Whether the request can change server state.
  final bool isMutating;
  final CancelToken? cancelToken;

  /// Called once when the request is aborted (closes the HTTP client, which
  /// tears down the connection).
  final void Function() onAbort;

  final Stream<bool> _connectivity;
  StreamSubscription<bool>? _subscription;
  final Completer<Never> _aborted = Completer<Never>();

  /// True once the request was cancelled or dropped; auth retries check this.
  bool get isAborted => _aborted.isCompleted;

  /// Runs [action], completing early with an [APIError] if aborted.
  Future<T> run<T>(Future<T> Function() action) {
    final token = cancelToken;
    if (token != null && token.isCancelled) {
      return Future.error(const APIError(APIErrorType.cancelled));
    }

    final result = Completer<T>();

    void abort(APIError error) {
      if (isAborted) return;
      _aborted.completeError(error);
      _aborted.future.ignore();
      onAbort();
      if (!result.isCompleted) result.completeError(error);
    }

    token?.whenCancelled
        .then((_) => abort(const APIError(APIErrorType.cancelled)));
    _subscription = _connectivity.listen(
      (online) {
        if (online) return;
        abort(
          APIError(
            isMutating
                ? APIErrorType.connectionLostDuringRequest
                : APIErrorType.noNetwork,
          ),
        );
      },
      // A broken connectivity plugin must never fail the request.
      onError: (Object _) {},
    );

    action().then((value) {
      if (!result.isCompleted) result.complete(value);
    }, onError: (Object error, StackTrace stack) {
      if (!result.isCompleted) result.completeError(error, stack);
    });

    return result.future;
  }

  /// Stops listening. Always call when the request is finished.
  void dispose() => _subscription?.cancel();
}
