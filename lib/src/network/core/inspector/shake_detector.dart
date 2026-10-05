/// Shake Gesture Detector for LDFlutter Networking Layer
library;

import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Detects a device shake gesture and invokes [onShake].
///
/// On iOS this listens to the native `motionEnded` shake gesture (the same
/// mechanism as "Shake to Undo"), via [ShakeDetectorPlugin] — this fires
/// correctly in both the Simulator (Device > Shake Gesture) and on real
/// devices. On other platforms it falls back to accelerometer-magnitude
/// thresholding via `sensors_plus`, debounced by [minGapBetweenShakes] to
/// avoid repeated triggers from a single continuous shake.
class ShakeDetector {
  static const EventChannel _iosShakeChannel =
      EventChannel('bm_flutter_networking/shake');

  final VoidCallback onShake;
  final double shakeThreshold;
  final Duration minGapBetweenShakes;

  StreamSubscription<UserAccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<dynamic>? _iosShakeSubscription;
  DateTime? _lastShakeTime;

  ShakeDetector({
    required this.onShake,
    this.shakeThreshold = 18,
    this.minGapBetweenShakes = const Duration(seconds: 1),
  });

  void startListening() {
    if (!kIsWeb && Platform.isIOS) {
      _iosShakeSubscription =
          _iosShakeChannel.receiveBroadcastStream().listen((_) => onShake());
      return;
    }
    _accelerometerSubscription =
        userAccelerometerEventStream().listen(_onEvent);
  }

  void stopListening() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _iosShakeSubscription?.cancel();
    _iosShakeSubscription = null;
  }

  void _onEvent(UserAccelerometerEvent event) {
    final magnitude =
        sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
    if (magnitude < shakeThreshold) return;

    final now = DateTime.now();
    if (_lastShakeTime != null &&
        now.difference(_lastShakeTime!) < minGapBetweenShakes) {
      return;
    }
    _lastShakeTime = now;
    onShake();
  }
}
