/// Global configuration for BMFlutter Networking Layer.
library;

import 'encryption/payload_encryptor.dart';

/// Global, app-wide networking settings. Configure once in `main()` (per
/// environment); every request reads them when it is built.
///
/// ```dart
/// NetworkConfig.configure(
///   payloadEncryptor: HybridPayloadEncryptor(publicKeyPem: Env.encryptPublicKey),
///   isPayloadEncryptionEnabled: !Env.isDevelopment,
///   receiveTimeout: const Duration(seconds: 45),
/// );
/// ```
class NetworkConfig {
  NetworkConfig._();

  /// Encrypts request bodies. Null disables encryption.
  static PayloadEncryptor? payloadEncryptor;

  /// Master switch for encryption, so it can be turned off per environment
  /// without removing the encryptor. Encryption only happens when this is true
  /// and [payloadEncryptor] is set.
  static bool isPayloadEncryptionEnabled = true;

  /// Also encrypt the query string of GET requests: the parameters are replaced
  /// by the encrypted envelope fields. Off by default; only enable it when the
  /// backend decrypts query strings.
  static bool encryptQueryParameters = false;

  /// Maximum time to open the connection (TCP + TLS). Null (the default) leaves
  /// it to the platform and relies on [sendTimeout]; when set, the request uses
  /// a dedicated `dart:io` client, so it is not mockable with
  /// `http.runWithClient`. Ignored on web.
  static Duration? connectTimeout;

  /// Maximum time from sending the request until the response headers arrive.
  static Duration? sendTimeout = const Duration(seconds: 30);

  /// Maximum time to read the response body.
  static Duration? receiveTimeout = const Duration(seconds: 30);

  /// Sets several options at once; omitted arguments keep their value.
  static void configure({
    PayloadEncryptor? payloadEncryptor,
    bool? isPayloadEncryptionEnabled,
    bool? encryptQueryParameters,
    Duration? connectTimeout,
    Duration? sendTimeout,
    Duration? receiveTimeout,
  }) {
    if (payloadEncryptor != null) {
      NetworkConfig.payloadEncryptor = payloadEncryptor;
    }
    if (isPayloadEncryptionEnabled != null) {
      NetworkConfig.isPayloadEncryptionEnabled = isPayloadEncryptionEnabled;
    }
    if (encryptQueryParameters != null) {
      NetworkConfig.encryptQueryParameters = encryptQueryParameters;
    }
    if (connectTimeout != null) NetworkConfig.connectTimeout = connectTimeout;
    if (sendTimeout != null) NetworkConfig.sendTimeout = sendTimeout;
    if (receiveTimeout != null) NetworkConfig.receiveTimeout = receiveTimeout;
  }

  /// Restores the defaults (mainly for tests).
  static void reset() {
    payloadEncryptor = null;
    isPayloadEncryptionEnabled = true;
    encryptQueryParameters = false;
    connectTimeout = null;
    sendTimeout = const Duration(seconds: 30);
    receiveTimeout = const Duration(seconds: 30);
  }

  /// Whether a request body should be encrypted.
  static bool get shouldEncrypt =>
      isPayloadEncryptionEnabled && payloadEncryptor != null;
}
