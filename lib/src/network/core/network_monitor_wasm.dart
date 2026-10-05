/// WASM stub for NetworkMonitor.
///
/// connectivity_plus uses dart:html internally and is not WASM-compatible.
/// On WASM targets, connectivity checks are skipped — if there is no network,
/// the HTTP request itself will fail and be reported as a network error.
library;

import 'package:flutter/foundation.dart';

/// Provides real-time and on-demand network connectivity status monitoring
class NetworkMonitor {
  const NetworkMonitor._();

  @visibleForTesting
  static NetworkMonitor createForTesting() => const NetworkMonitor._();

  /// Always returns `true` on WASM. Network errors surface as HTTP failures.
  static Future<bool> get isConnected async => true;

  /// Returns an empty stream on WASM — connectivity events are not available.
  static Stream<bool> get onConnectivityChanged => const Stream.empty();
}
