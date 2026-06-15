// Conditional export: connectivity_plus is not WASM-compatible.
// On WASM (no dart:io, no dart:html), the stub is used so the package
// remains WASM-compatible. Native and web builds use connectivity_plus.
export 'network_monitor_wasm.dart'
    if (dart.library.io) 'network_monitor_connectivity.dart'
    if (dart.library.html) 'network_monitor_connectivity.dart';
