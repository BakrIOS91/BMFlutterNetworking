/// Platform-agnostic HTTP cookie representation.
library;

class BMCookie {
  final String name;
  final String value;
  final String? domain;
  final String? path;
  final bool httpOnly;
  final bool secure;

  const BMCookie({
    required this.name,
    required this.value,
    this.domain,
    this.path,
    this.httpOnly = false,
    this.secure = false,
  });

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
