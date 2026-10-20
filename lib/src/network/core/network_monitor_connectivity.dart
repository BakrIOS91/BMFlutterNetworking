/// Network Connectivity Monitor for BMFlutter Networking Layer
///
/// Keeps a single, app-wide subscription to the platform connectivity stream.
/// On iOS, `connectivity_plus` stops and discards its `NWPathMonitor` when the
/// last stream listener cancels; the next `checkConnectivity()` then creates a
/// fresh monitor and reads its path before it has been evaluated, reporting
/// `none` while the device is online. Holding one subscription open keeps the
/// native monitor alive, so checks always read an up-to-date path.
library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'connectivity_provider.dart';

/// Provides real-time and on-demand network connectivity status monitoring
class NetworkMonitor {
  const NetworkMonitor._();

  @visibleForTesting
  static NetworkMonitor createForTesting() => const NetworkMonitor._();

  /// Delay before re-checking when a check reports offline, to ride out a
  /// platform monitor that has not evaluated its first path yet.
  static Duration offlineRecheckDelay = const Duration(milliseconds: 500);

  static final _changes = StreamController<bool>.broadcast();
  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  static ConnectivityProvider? _provider;

  /// Replaces the platform connectivity source with [provider] (pass `null`
  /// to go back to `connectivity_plus`). While a provider is set,
  /// `connectivity_plus` is not used at all, which is what you want on a
  /// platform where that plugin has no implementation.
  static void useProvider(ConnectivityProvider? provider) {
    _provider = provider;
    if (provider != null) {
      _subscription?.cancel();
      _subscription = null;
    }
  }

  /// Starts monitoring. Called automatically on first use; calling it early
  /// (e.g. in `main`) only warms up the platform monitor.
  static void start() {
    if (_subscription != null ||
        connectivityOverride != null ||
        _provider != null) {
      return;
    }
    try {
      _subscription = Connectivity().onConnectivityChanged.listen(
        (results) => _changes.add(_isOnline(results)),
        onError: (_) {},
        // Re-subscribe on next use if the platform stream ever ends.
        onDone: () => _subscription = null,
      );
    } catch (_) {
      // Platform channel unavailable; checks still work on demand.
    }
  }

  /// Stops monitoring. For tests.
  @visibleForTesting
  static Future<void> reset() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  static Future<bool> get isConnected async {
    final provider = _provider;
    if (provider != null && connectivityOverride == null) {
      return provider.isOnline();
    }
    start();
    if (await _check()) return true;
    await Future<void>.delayed(offlineRecheckDelay);
    return _check();
  }

  static Future<bool> _check() async =>
      _isOnline(await Connectivity().checkConnectivity());

  /// Replaces [onConnectivityChanged] in tests.
  @visibleForTesting
  static Stream<bool>? connectivityOverride;

  /// Emits every change only, without the current status on listen. Used by
  /// request guards so a stale status never cancels a new request.
  static Stream<bool> get changes {
    final override = connectivityOverride;
    if (override != null) return override;
    final provider = _provider;
    if (provider != null) return provider.onChanged;
    start();
    return _changes.stream;
  }

  /// Emits the current status on listen, then every change.
  static Stream<bool> get onConnectivityChanged {
    final override = connectivityOverride;
    if (override != null) return override;
    final provider = _provider;
    if (provider != null) {
      return (() async* {
        yield await provider.isOnline();
        yield* provider.onChanged;
      })().asBroadcastStream();
    }
    start();

    StreamSubscription<bool>? changes;
    late final StreamController<bool> controller;
    controller = StreamController<bool>.broadcast(
      onListen: () {
        var changed = false;
        changes = _changes.stream.listen((online) {
          changed = true;
          controller.add(online);
        });
        // The shared platform subscription already consumed its initial
        // event, so seed late listeners with a fresh check.
        _check().then((online) {
          if (!changed && !controller.isClosed) controller.add(online);
        }, onError: (_) {});
      },
      onCancel: () => changes?.cancel(),
    );
    return controller.stream;
  }

  /// Any active interface counts as online (wifi, mobile, ethernet, vpn,
  /// bluetooth tethering, other). Android only reports a type when the network
  /// has internet capability, so only an explicit `none` means offline.
  static bool _isOnline(List<ConnectivityResult> results) =>
      results.any((result) => result != ConnectivityResult.none);
}
