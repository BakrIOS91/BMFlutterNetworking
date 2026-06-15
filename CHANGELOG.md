## 0.1.5

* Added web platform support via conditional imports.
* Replaced `dart:io` Cookie with platform-agnostic `BMCookie` class.
* File I/O (upload/download) isolated behind conditional exports; throws `UnsupportedError` on web.
* `SSLPinningHelper` isolated behind conditional exports; throws `UnsupportedError` on web (browsers handle TLS natively).

## 0.1.4

* Re-publish to resolve version conflict on pub.dev.

## 0.1.3

* Declared explicit platform support: Android, iOS, macOS, Windows, Linux.

## 0.1.2

* Fixed homepage URL in pubspec.yaml.
* Added example app demonstrating `Target`, `ModelTargetType`, and `performAsync`.

## 0.1.1

* Bumped `connectivity_plus` constraint to `^7.1.1`.

## 0.1.0

* Initial release.
* Type-safe network layer with `Target`, `ModelTargetType`, and `SuccessTargetType`.
* Automatic token refresh via `TokenRefreshHandler`.
* Custom error mapping via `APIErrorResponseMapper`.
* SSL certificate pinning.
* Built-in logging and connectivity monitoring.
* File upload and download support.
* `Result<T, E>` type for explicit error handling.
