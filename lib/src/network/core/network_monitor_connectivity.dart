/// Network Connectivity Monitor for BMFlutter Networking Layer
library;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Provides real-time and on-demand network connectivity status monitoring
class NetworkMonitor {
  const NetworkMonitor._();

  @visibleForTesting
  static NetworkMonitor createForTesting() => const NetworkMonitor._();

  static Future<bool> get isConnected async {
    final results = await Connectivity().checkConnectivity();
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }

  static Stream<bool> get onConnectivityChanged =>
      Connectivity().onConnectivityChanged.map((results) {
        return results.contains(ConnectivityResult.mobile) ||
            results.contains(ConnectivityResult.wifi) ||
            results.contains(ConnectivityResult.ethernet);
      });
}
