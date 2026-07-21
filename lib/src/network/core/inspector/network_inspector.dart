/// Network Inspector Store for LDFlutter Networking Layer
library;

import 'package:flutter/foundation.dart';

import 'network_log_entry.dart';

/// In-memory store of captured [NetworkLogEntry] items, fed by
/// [LoggingInterceptor] and rendered by [NetworkInspectorOverlay].
class NetworkInspector {
  NetworkInspector._();

  static final NetworkInspector instance = NetworkInspector._();

  static const int maxEntries = 200;

  int _nextId = 0;

  final ValueNotifier<List<NetworkLogEntry>> logs =
      ValueNotifier<List<NetworkLogEntry>>([]);

  /// Appearance of the inspector UI itself, independent of the host app's
  /// own theme. Toggle from the log list's app bar.
  final ValueNotifier<Brightness> brightness =
      ValueNotifier<Brightness>(Brightness.dark);

  void toggleBrightness() {
    brightness.value = brightness.value == Brightness.dark
        ? Brightness.light
        : Brightness.dark;
  }

  NetworkLogEntry logRequest({
    required String method,
    required Uri url,
    Map<String, String>? headers,
    Uint8List? body,
  }) {
    final entry = NetworkLogEntry(
      id: '${_nextId++}',
      method: method,
      url: url,
      requestHeaders: Map<String, String>.from(headers ?? {}),
      requestBody: body,
      startTime: DateTime.now(),
    );

    final updated = [entry, ...logs.value];
    if (updated.length > maxEntries) {
      updated.removeRange(maxEntries, updated.length);
    }
    logs.value = updated;
    return entry;
  }

  void logResponse({
    required NetworkLogEntry? entry,
    required int statusCode,
    Map<String, String>? headers,
    Uint8List? body,
    Duration? duration,
  }) {
    if (entry == null) return;
    entry.statusCode = statusCode;
    entry.responseHeaders = headers;
    entry.responseBody = body;
    entry.duration = duration;
    logs.value = [...logs.value];
  }

  void logError({
    required NetworkLogEntry? entry,
    required Object error,
    Duration? duration,
  }) {
    if (entry == null) return;
    entry.error = error;
    entry.duration = duration;
    logs.value = [...logs.value];
  }

  void clear() => logs.value = [];
}
