/// Network Response Wrapper for BMFlutter Networking Layer
library;

import 'dart:io';

/// Network response wrapper containing decoded data and response metadata.
class NetworkResponse<T> {
  final T data;
  final int statusCode;
  final Map<String, String> headers;
  final String? rawSetCookieHeader;
  final List<Cookie> cookies;

  const NetworkResponse({
    required this.data,
    required this.statusCode,
    required this.headers,
    required this.rawSetCookieHeader,
    required this.cookies,
  });

  String? get cookieHeader {
    if (cookies.isEmpty) return null;
    return cookies.map((c) => '${c.name}=${c.value}').join('; ');
  }
}

/// Best-effort parsing for Set-Cookie header into Cookie objects.
List<Cookie> parseSetCookieHeader(String? headerValue) {
  if (headerValue == null || headerValue.trim().isEmpty) return const [];

  final parts = _splitSetCookie(headerValue);
  final cookies = <Cookie>[];
  for (final part in parts) {
    try {
      cookies.add(Cookie.fromSetCookieValue(part));
    } catch (_) {
      // Ignore malformed cookie parts
    }
  }
  return cookies;
}

List<String> _splitSetCookie(String headerValue) {
  final parts = <String>[];
  var start = 0;
  var inExpires = false;
  final lower = headerValue.toLowerCase();

  for (var i = 0; i < headerValue.length; i++) {
    if (!inExpires &&
        i + 8 <= headerValue.length &&
        lower.substring(i, i + 8) == 'expires=') {
      inExpires = true;
    }

    if (inExpires && headerValue[i] == ';') {
      inExpires = false;
    }

    if (headerValue[i] == ',' && !inExpires) {
      final part = headerValue.substring(start, i).trim();
      if (part.isNotEmpty) parts.add(part);
      start = i + 1;
    }
  }

  final last = headerValue.substring(start).trim();
  if (last.isNotEmpty) parts.add(last);

  return parts;
}
