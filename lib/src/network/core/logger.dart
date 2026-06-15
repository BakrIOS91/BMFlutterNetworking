/// Network Logger for BMFlutter Networking Layer
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Logger helper for HTTP requests and responses with formatted output
class Logger {
  static bool isEnabled = kDebugMode;

  static void logRequest({
    required String method,
    required Uri url,
    Map<String, String>? headers,
    Map<String, dynamic>? parameters,
    dynamic body,
  }) {
    if (!isEnabled) return;

    _safeLog(
      '############################## Request ##############################',
    );
    _safeLog('📤 Will send $method request for $url\n');

    if (headers != null && headers.isNotEmpty) {
      _safeLog('🏷 Headers:');
      headers.forEach((key, value) => _safeLog('$key : $value'));
    }

    if (parameters != null && parameters.isNotEmpty) {
      _safeLog('\nParameters: ${_prettyPrintJson(parameters)}\n');
    }

    if (body != null) {
      String bodyStr = '';
      if (body is String) {
        try {
          final decoded = json.decode(body);
          if (decoded is Map || decoded is List) {
            bodyStr = _prettyPrintJson(decoded);
          } else {
            bodyStr = body;
          }
        } catch (_) {
          bodyStr = body;
        }
      } else if (body is Uint8List) {
        bodyStr = _prettyPrintBody(body);
      } else if (body is Map || body is List) {
        bodyStr = _prettyPrintJson(body);
      } else {
        bodyStr = body.toString();
      }

      _safeLog('\nBody: $bodyStr\n');
    } else {
      _safeLog('\nBody: Empty\n');
    }

    _safeLog(
      '############################## End Request ##############################\n',
    );
  }

  static void logResponse({
    required String method,
    required Uri url,
    int? statusCode,
    Uint8List? responseData,
    Object? error,
  }) {
    if (!isEnabled) return;

    _safeLog(
      '############################## Received Response ##############################',
    );

    if (error != null) {
      _safeLog('❌ $statusCode $method request for $url returned Error: $error');
    }

    if (statusCode != null) {
      final statusEmoji = (statusCode >= 200 && statusCode < 300) ? '✅' : '⚠️';
      _safeLog(
        '$statusEmoji Did receive response $statusCode for request $url',
      );

      if (responseData != null && responseData.isNotEmpty) {
        _safeLog('\nBody:\n${_prettyPrintBody(responseData)}');
      } else {
        _safeLog('\nBody: Empty or Void...');
      }
    }

    _safeLog(
      '############################## End Response ##############################\n',
    );
  }

  static void _safeLog(String message) {
    if (isEnabled) debugPrint(message, wrapWidth: 1024);
  }

  static String _prettyPrintJson(dynamic json) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(json);
    } catch (_) {
      return json.toString();
    }
  }

  static String _prettyPrintBody(Uint8List body) {
    try {
      final decoded = utf8.decode(body);
      final jsonBody = json.decode(decoded);
      return _prettyPrintJson(jsonBody);
    } catch (_) {
      return utf8.decode(body, allowMalformed: true);
    }
  }
}
