/// Result Type for BMFlutter Networking Layer
library;

/// Represents the result of an operation: either success or failure
sealed class Result<S, E> {
  const Result();

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

  S? get value => this is Success<S, E> ? (this as Success<S, E>).value : null;
  E? get error => this is Failure<S, E> ? (this as Failure<S, E>).error : null;
  bool get isSuccess => this is Success<S, E>;
  bool get isFailure => this is Failure<S, E>;
}

class Success<S, E> extends Result<S, E> {
  @override
  final S value;

  const Success(this.value);
}

class Failure<S, E> extends Result<S, E> {
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
