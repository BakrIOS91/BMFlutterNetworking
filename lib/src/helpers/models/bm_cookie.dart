/// Platform-agnostic HTTP cookie representation.
library;

/// A platform-agnostic representation of an HTTP cookie parsed from a
/// `Set-Cookie` response header.
///
/// Unlike `dart:io`'s `Cookie`, this class works on all Flutter platforms
/// including web.
class BMCookie {
  /// The cookie name.
  final String name;

  /// The cookie value.
  final String value;

  /// The `Domain` attribute, or `null` if not set.
  final String? domain;

  /// The `Path` attribute, or `null` if not set.
  final String? path;

  /// Whether the `HttpOnly` flag is set.
  final bool httpOnly;

  /// Whether the `Secure` flag is set.
  final bool secure;

  /// Creates a [BMCookie] with the given [name] and [value].
  const BMCookie({
    required this.name,
    required this.value,
    this.domain,
    this.path,
    this.httpOnly = false,
    this.secure = false,
  });

  /// Parses a single `Set-Cookie` header value into a [BMCookie].
  ///
  /// Attributes such as `Path`, `Domain`, `HttpOnly`, and `Secure` are
  /// extracted when present. Unknown attributes are silently ignored.
  factory BMCookie.fromSetCookieValue(String cookieString) {
    final parts = cookieString.split(';');
    final nameValue = parts.first.trim();
    final eqIdx = nameValue.indexOf('=');
    final name = eqIdx >= 0 ? nameValue.substring(0, eqIdx).trim() : nameValue;
    final value = eqIdx >= 0 ? nameValue.substring(eqIdx + 1).trim() : '';

    String? domain;
    String? path;
    var httpOnly = false;
    var secure = false;

    for (final attr in parts.skip(1)) {
      final trimmed = attr.trim();
      final lower = trimmed.toLowerCase();
      if (lower == 'httponly') {
        httpOnly = true;
      } else if (lower == 'secure') {
        secure = true;
      } else if (lower.startsWith('domain=')) {
        domain = trimmed.substring(7);
      } else if (lower.startsWith('path=')) {
        path = trimmed.substring(5);
      }
    }

    return BMCookie(
      name: name,
      value: value,
      domain: domain,
      path: path,
      httpOnly: httpOnly,
      secure: secure,
    );
  }
}
