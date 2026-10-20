/// WASM stub for NetworkMonitor.
///
/// connectivity_plus uses dart:html internally and is not WASM-compatible.
/// On WASM targets, connectivity checks are skipped — if there is no network,
/// the HTTP request itself will fail and be reported as a network error.
library;

import 'package:flutter/foundation.dart';

import 'connectivity_provider.dart';

/// Provides real-time and on-demand network connectivity status monitoring
class NetworkMonitor {
  const NetworkMonitor._();

  @visibleForTesting
  static NetworkMonitor createForTesting() => const NetworkMonitor._();

  static ConnectivityProvider? _provider;

  /// Uses [provider] as the connectivity source (pass `null` to remove it).
  /// Without a provider, WASM reports online and emits no events.
  static void useProvider(ConnectivityProvider? provider) =>
      _provider = provider;

  /// No-op on WASM.
  static void start() {}

  /// `true` on WASM unless a provider is registered. Network errors surface
  /// as HTTP failures.
  static Future<bool> get isConnected async =>
      _provider == null ? true : _provider!.isOnline();

  /// Provider changes, or an empty stream when no provider is registered.
  static Stream<bool> get changes =>
      _provider?.onChanged ?? const Stream.empty();

  /// Current status then changes with a provider; an empty stream without one.
  static Stream<bool> get onConnectivityChanged {
    final provider = _provider;
    if (provider == null) return const Stream.empty();
    return (() async* {
      yield await provider.isOnline();
      yield* provider.onChanged;
    })().asBroadcastStream();
  }
}
