## 0.1.9

* Fixed WASM incompatibility: `NetworkMonitor` now uses conditional exports so `connectivity_plus` (which uses `dart:html` internally) is not imported on WASM targets.
* On WASM, `NetworkMonitor.isConnected` returns `true` and `onConnectivityChanged` returns an empty stream; network failures surface as HTTP errors directly.

## 0.1.8

* Fixed security issue: `SSLPinningHelper` no longer accepts TLS-invalid certificates for non-pinned hosts when `allowFallback` is true — `allowFallback` now only applies to pinned hosts where pinning validation fails.
* Fixed file sink not being closed on error in `saveStreamToTemp` (native file download).
* Fixed `UnsupportedError` from web file I/O being swallowed and misreported as `invalidURL` on the `ModelTargetType` path.
* Documented that `DownloadedFile.response.stream` is already consumed after `performDownload` completes.

## 0.1.7

* Added dartdoc comments to public API elements to exceed 20% documentation threshold.
* Removed redundant `bm_cookie.dart` import in `perform_async.dart` (already re-exported via `network_response.dart`).

## 0.1.6

* Added unit tests for `BMCookie` and web platform stubs.
* Updated README with platform support table, `BMCookie` docs, and web caveats.

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
