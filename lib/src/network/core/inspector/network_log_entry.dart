/// Network Inspector Log Entry for LDFlutter Networking Layer
library;

import 'dart:typed_data';

/// A single captured request/response pair shown by the network inspector.
class NetworkLogEntry {
  final String id;
  final String method;
  final Uri url;
  final Map<String, String> requestHeaders;
  final Uint8List? requestBody;
  final DateTime startTime;

  int? statusCode;
  Map<String, String>? responseHeaders;
  Uint8List? responseBody;
  Object? error;
  Duration? duration;

  NetworkLogEntry({
    required this.id,
    required this.method,
    required this.url,
    required this.requestHeaders,
    required this.requestBody,
    required this.startTime,
  });

  bool get isPending => statusCode == null && error == null;

  bool get isError =>
      error != null || (statusCode != null && statusCode! >= 400);
}
