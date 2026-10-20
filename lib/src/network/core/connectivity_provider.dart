/// Source of connectivity information for [NetworkMonitor].
///
/// By default [NetworkMonitor] reads the platform through `connectivity_plus`.
/// Register your own provider with [NetworkMonitor.useProvider] when that
/// plugin is not available (some TV platforms), or when another signal is
/// more accurate for your app, such as a messaging client's own connection
/// state. While a provider is registered, `connectivity_plus` is never called.
library;

abstract interface class ConnectivityProvider {
  /// Whether the device is online right now.
  Future<bool> isOnline();

  /// Emits `true` or `false` whenever connectivity changes. It must not emit
  /// the current status when listened to; [NetworkMonitor] adds that itself
  /// where needed.
  Stream<bool> get onChanged;
}
