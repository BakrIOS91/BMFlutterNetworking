/// Result Type for BMFlutter Networking Layer
library;

/// Represents the result of an operation: either success or failure.
///
/// Use [when] to handle both outcomes, or check [isSuccess]/[isFailure]
/// before accessing [value]/[error].
sealed class Result<S, E> {
  const Result();

  /// Calls [success] with the value if this is a [Success], or [failure]
  /// with the error if this is a [Failure].
  void when({
    required void Function(S value) success,
    required void Function(E error) failure,
  }) {
    if (this is Success<S, E>) {
      success((this as Success<S, E>).value);
    } else if (this is Failure<S, E>) {
      failure((this as Failure<S, E>).error);
    }
  }

  /// The success value, or `null` if this is a [Failure].
  S? get value => this is Success<S, E> ? (this as Success<S, E>).value : null;

  /// The failure error, or `null` if this is a [Success].
  E? get error => this is Failure<S, E> ? (this as Failure<S, E>).error : null;

  /// Whether this result represents a success.
  bool get isSuccess => this is Success<S, E>;

  /// Whether this result represents a failure.
  bool get isFailure => this is Failure<S, E>;
}

/// A successful [Result] carrying a value of type [S].
class Success<S, E> extends Result<S, E> {
  /// The success value.
  @override
  final S value;

  const Success(this.value);
}

/// A failed [Result] carrying an error of type [E].
class Failure<S, E> extends Result<S, E> {
  /// The failure error.
  @override
  final E error;

  const Failure(this.error);
}

extension ResultMapping<S, E> on Result<S, E> {
  Result<R, E> map<R>(R Function(S value) transform) {
    if (this is Success<S, E>) {
      return Success<R, E>(transform((this as Success<S, E>).value));
    } else {
      return Failure<R, E>((this as Failure<S, E>).error);
    }
  }

  Result<S, F> mapError<F>(F Function(E error) transform) {
    if (this is Failure<S, E>) {
      return Failure<S, F>(transform((this as Failure<S, E>).error));
    } else {
      return Success<S, F>((this as Success<S, E>).value);
    }
  }
}
