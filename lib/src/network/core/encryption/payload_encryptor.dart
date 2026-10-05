/// Request payload encryption for BMFlutter Networking Layer.
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart';

import '../../../helpers/api_error.dart';

/// Turns a request body into the encrypted envelope that is sent instead of it.
abstract class PayloadEncryptor {
  /// Returns a JSON-encodable object that replaces [body] on the wire.
  Object encrypt(Object? body);
}

/// How the AES key is wrapped with the RSA public key.
enum RsaPadding {
  /// RSAES-PKCS1-v1_5. What JSEncrypt, OpenSSL `RSA_PKCS1_PADDING` and PHP
  /// `openssl_private_decrypt` default to.
  pkcs1v15,

  /// RSAES-OAEP with SHA-1.
  oaepSha1,

  /// RSAES-OAEP with SHA-256.
  oaepSha256,
}

/// What is encrypted with the RSA key.
enum AesKeyFormat {
  /// The lowercase hex string of the key (32 characters for AES-128), as UTF-8
  /// bytes. This is what `CryptoJS` / `JSEncrypt` based clients send.
  hexString,

  /// The raw key bytes.
  rawBytes,
}

/// Hybrid encryption: a fresh AES-CBC key and IV are generated for every
/// request, the body is encrypted with them, and the AES key is wrapped with
/// the server RSA public key.
///
/// The envelope is `{ "data": base64(cipher), "iv": base64(iv), "key":
/// base64(rsa(aesKey)) }`; the field names can be changed with [dataField],
/// [ivField] and [keyField].
class HybridPayloadEncryptor implements PayloadEncryptor {
  /// [publicKeyPem] is an X.509 `BEGIN PUBLIC KEY` or PKCS#1 `BEGIN RSA PUBLIC
  /// KEY` PEM. Literal `\n` sequences (single-line env values) are accepted.
  HybridPayloadEncryptor({
    required String publicKeyPem,
    this.rsaPadding = RsaPadding.pkcs1v15,
    this.aesKeyFormat = AesKeyFormat.hexString,
    this.aesKeyBits = 128,
    this.dataField = 'data',
    this.ivField = 'iv',
    this.keyField = 'key',
    Random? random,
  })  : assert(aesKeyBits == 128 || aesKeyBits == 192 || aesKeyBits == 256),
        _random = random ?? Random.secure(),
        _publicKey = parseRsaPublicKey(publicKeyPem);

  final RsaPadding rsaPadding;
  final AesKeyFormat aesKeyFormat;
  final int aesKeyBits;
  final String dataField;
  final String ivField;
  final String keyField;

  final Random _random;
  final RSAPublicKey _publicKey;

  @override
  Object encrypt(Object? body) {
    try {
      final aesKey = _randomBytes(aesKeyBits ~/ 8);
      final iv = _randomBytes(16);

      final cipher = PaddedBlockCipherImpl(
        PKCS7Padding(),
        CBCBlockCipher(AESEngine()),
      )..init(
          true,
          PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
            ParametersWithIV(KeyParameter(aesKey), iv),
            null,
          ),
        );
      final data =
          cipher.process(Uint8List.fromList(utf8.encode(jsonEncode(body))));

      final keyPlain = aesKeyFormat == AesKeyFormat.hexString
          ? Uint8List.fromList(utf8.encode(_hex(aesKey)))
          : aesKey;
      final wrappedKey = _rsa().process(keyPlain);

      return {
        dataField: base64Encode(data),
        ivField: base64Encode(iv),
        keyField: base64Encode(wrappedKey),
      };
    } on APIError {
      rethrow;
    } catch (_) {
      throw const APIError(APIErrorType.encryptionFailed);
    }
  }

  AsymmetricBlockCipher _rsa() {
    final AsymmetricBlockCipher engine = switch (rsaPadding) {
      RsaPadding.pkcs1v15 => PKCS1Encoding(RSAEngine()),
      RsaPadding.oaepSha1 => OAEPEncoding(RSAEngine()),
      RsaPadding.oaepSha256 => OAEPEncoding.withSHA256(RSAEngine()),
    };
    return engine..init(true, PublicKeyParameter<RSAPublicKey>(_publicKey));
  }

  Uint8List _randomBytes(int length) =>
      Uint8List.fromList(List.generate(length, (_) => _random.nextInt(256)));

  static String _hex(Uint8List bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

  /// Parses an RSA public key from an X.509 or PKCS#1 PEM string.
  static RSAPublicKey parseRsaPublicKey(String pem) {
    try {
      final normalized = pem.replaceAll(r'\n', '\n').trim();
      final isPkcs1 = normalized.contains('BEGIN RSA PUBLIC KEY');
      final der = base64Decode(
        normalized
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty && !l.startsWith('-----'))
            .join(),
      );

      var rsaSequence = ASN1Parser(der).nextObject() as ASN1Sequence;
      if (!isPkcs1) {
        final bitString = rsaSequence.elements![1] as ASN1BitString;
        rsaSequence = ASN1Parser(Uint8List.fromList(bitString.stringValues!))
            .nextObject() as ASN1Sequence;
      }
      return RSAPublicKey(
        (rsaSequence.elements![0] as ASN1Integer).integer!,
        (rsaSequence.elements![1] as ASN1Integer).integer!,
      );
    } catch (_) {
      throw const APIError(APIErrorType.encryptionFailed);
    }
  }
}
