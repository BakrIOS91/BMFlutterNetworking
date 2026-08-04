## 0.2.1

* Fixed `ModelTargetType` requests crashing with `TypeError: type 'List<dynamic>' is not a subtype of type 'Map<String, dynamic>'` for any endpoint whose success response is a top-level JSON array. The internal decode call was statically typed against `fromJson(Map<String, dynamic>)`, so Dart inserted an implicit downcast before dispatch, regardless of the target's own override.
* Added `ModelTargetType.fromDynamicJson(dynamic json)` — override this instead of `fromJson` when a response's top-level JSON shape isn't a `Map` (e.g. an array). Defaults to forwarding to `fromJson`, so every existing object-returning target is unaffected; no changes needed unless you decode a top-level array.

## 0.2.0

* Added an in-app network inspector: shake the device to open a bottom sheet listing every captured request, with search, a light/dark theme toggle, and a detail screen (real push/pop navigation, copy-to-clipboard) for headers and bodies. Gated by the existing `Logger.isEnabled` flag.
* On iOS, shake detection uses the native `motionEnded` gesture (works in the Simulator's Device > Shake Gesture, not just on real devices) via a small bundled native plugin.
* On other platforms, shake detection falls back to `sensors_plus` accelerometer thresholding.
* `NetworkLogListPage` and `NetworkLogDetailPage` are also exported standalone for apps that want to push them from their own debug menu instead of the shake gesture.

## 0.1.12

* Added full production example app: Supabase backend, BLoC + Freezed state management, `WithViewState` error handling, `auto_route` navigation, and `envied`-based config with test credentials pre-filled.

## 0.1.11

* Added `errorModelAs<T>()` to `APIError` — typed accessor for the decoded error payload, replacing the double-cast pattern `(apiError.errorModel as T?)` with `apiError.errorModelAs<T>()`.

## 0.1.10

* Fixed WASM incompatibility caused by `file_io.dart` and `ssl_pinning_helper.dart` falling back to the native (`dart:io`) implementation when `dart.library.html` is absent — which is the case on both native AND WASM. Conditional exports now default to the web stub and only opt into native when `dart.library.io` is explicitly available.

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
