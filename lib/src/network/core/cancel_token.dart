/// Request cancellation for BMFlutter Networking Layer.
library;

import 'dart:async';

/// Cancels one or more in-flight requests.
///
/// ```dart
/// final token = CancelToken();
/// final result = await request.performResult(cancelToken: token);
/// // later, e.g. in BLoC.close():
/// token.cancel();
/// ```
/// A cancelled request completes with `APIError(APIErrorType.cancelled)`.
/// One token may be shared by several requests; it cannot be reused after
/// [cancel] (create a new one).
class CancelToken {
  final Completer<void> _completer = Completer<void>();
  String? _reason;

  /// Whether [cancel] has been called.
  bool get isCancelled => _completer.isCompleted;

  /// The reason passed to [cancel], if any.
  String? get reason => _reason;

  /// Completes when the token is cancelled.
  Future<void> get whenCancelled => _completer.future;

  /// Cancels every request using this token. Safe to call more than once.
  void cancel([String? reason]) {
    if (_completer.isCompleted) return;
    _reason = reason;
    _completer.complete();
  }
}
