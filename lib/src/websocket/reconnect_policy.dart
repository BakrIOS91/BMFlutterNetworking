import 'dart:math';

/// Decides how long to wait before reconnect attempt number `attempt`
/// (starting at 1).
abstract class ReconnectPolicy {
  const ReconnectPolicy();

  /// Same delay every time.
  const factory ReconnectPolicy.fixed(Duration delay) = _FixedReconnectPolicy;

  /// Exponential backoff with jitter: `initial * factor^(attempt-1)`, capped at
  /// [max], randomised by up to ±[jitter] (0..1) to avoid reconnect storms.
  const factory ReconnectPolicy.exponential({
    Duration initial,
    Duration max,
    double factor,
    double jitter,
  }) = _ExponentialReconnectPolicy;

  /// Delay before reconnect attempt number [attempt].
  Duration delayFor(int attempt);
}

class _FixedReconnectPolicy extends ReconnectPolicy {
  const _FixedReconnectPolicy(this.delay);
  final Duration delay;

  @override
  Duration delayFor(int attempt) => delay;
}

class _ExponentialReconnectPolicy extends ReconnectPolicy {
  const _ExponentialReconnectPolicy({
    this.initial = const Duration(seconds: 1),
    this.max = const Duration(seconds: 30),
    this.factor = 2,
    this.jitter = 0.3,
  });

  final Duration initial;
  final Duration max;
  final double factor;
  final double jitter;

  static final _random = Random();

  @override
  Duration delayFor(int attempt) {
    final base = initial.inMilliseconds * pow(factor, attempt - 1);
    final capped = min(base, max.inMilliseconds.toDouble());
    final spread = (_random.nextDouble() * 2 - 1) * jitter;
    return Duration(milliseconds: (capped * (1 + spread)).round());
  }
}
