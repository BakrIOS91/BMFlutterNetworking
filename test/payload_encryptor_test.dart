import 'dart:convert';
import 'dart:typed_data';

import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart';

class _Keys {
  _Keys(this.pair) {
    pub = pair.publicKey as RSAPublicKey;
    priv = pair.privateKey as RSAPrivateKey;
  }
  final AsymmetricKeyPair<PublicKey, PrivateKey> pair;
  late final RSAPublicKey pub;
  late final RSAPrivateKey priv;

  static _Keys generate() {
    final generator = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64),
          FortunaRandom()..seed(KeyParameter(Uint8List(32))),
        ),
      );
    return _Keys(generator.generateKeyPair());
  }

  ASN1Sequence get _pkcs1 => ASN1Sequence(
        elements: [ASN1Integer(pub.modulus), ASN1Integer(pub.exponent)],
      );

  String get spkiPem {
    final spki = ASN1Sequence(elements: [
      ASN1Sequence(elements: [
        ASN1ObjectIdentifier.fromIdentifierString('1.2.840.113549.1.1.1'),
        ASN1Null(),
      ]),
      ASN1BitString(stringValues: _pkcs1.encode()),
    ]);
    return '-----BEGIN PUBLIC KEY-----\n${base64Encode(spki.encode())}\n-----END PUBLIC KEY-----';
  }

  String get pkcs1Pem =>
      '-----BEGIN RSA PUBLIC KEY-----\n${base64Encode(_pkcs1.encode())}\n-----END RSA PUBLIC KEY-----';
}

dynamic _decrypt(
  Map<String, dynamic> envelope,
  RSAPrivateKey key, {
  AsymmetricBlockCipher? rsa,
  bool hexKey = true,
}) {
  rsa ??= PKCS1Encoding(RSAEngine());
  rsa.init(false, PrivateKeyParameter<RSAPrivateKey>(key));
  final unwrapped = rsa.process(base64Decode(envelope['key']));
  final aesKey = hexKey
      ? Uint8List.fromList([
          for (final s in RegExp('..').allMatches(utf8.decode(unwrapped)))
            int.parse(s.group(0)!, radix: 16),
        ])
      : unwrapped;
  final aes = PaddedBlockCipherImpl(PKCS7Padding(), CBCBlockCipher(AESEngine()))
    ..init(
      false,
      PaddedBlockCipherParameters<ParametersWithIV<KeyParameter>, Null>(
        ParametersWithIV(KeyParameter(aesKey), base64Decode(envelope['iv'])),
        null,
      ),
    );
  return jsonDecode(utf8.decode(aes.process(base64Decode(envelope['data']))));
}

class _Post extends SuccessTargetType {
  _Post({this.optOut = false, this.method = HTTPMethod.post, this.task});
  final bool optOut;
  final HTTPMethod method;
  final RequestTask? task;

  @override
  String get baseURL => 'https://example.com/';
  @override
  String get requestPath => 'identity';
  @override
  HTTPMethod get requestMethod => method;
  @override
  bool get encryptsPayload => !optOut;
  @override
  RequestTask get requestTask =>
      task ?? RequestTask.encodedBody({'email': 'a@b.c'});
}

void main() {
  final keys = _Keys.generate();
  final body = {
    'email': 'a@b.c',
    'amount': '10.5',
    'nested': {'x': 1}
  };

  tearDown(NetworkConfig.reset);

  group('HybridPayloadEncryptor', () {
    test('PKCS#1 v1.5 with hex-string key (JSEncrypt/CryptoJS compatible)', () {
      final env = HybridPayloadEncryptor(publicKeyPem: keys.spkiPem)
          .encrypt(body) as Map<String, dynamic>;
      expect(env.keys, containsAll(['data', 'iv', 'key']));
      expect(base64Decode(env['iv']).length, 16);
      expect(_decrypt(env, keys.priv), body);
    });

    test('uses a fresh key and IV for every call', () {
      final enc = HybridPayloadEncryptor(publicKeyPem: keys.spkiPem);
      final a = enc.encrypt(body) as Map;
      final b = enc.encrypt(body) as Map;
      expect(a['iv'], isNot(b['iv']));
      expect(a['data'], isNot(b['data']));
    });

    test('accepts PKCS#1 PEM and single-line env values with literal \\n', () {
      final oneLine = keys.spkiPem.replaceAll('\n', r'\n');
      for (final pem in [keys.pkcs1Pem, oneLine]) {
        final env = HybridPayloadEncryptor(publicKeyPem: pem).encrypt(body)
            as Map<String, dynamic>;
        expect(_decrypt(env, keys.priv), body);
      }
    });

    test('OAEP and raw-byte keys, AES-256', () {
      final env = HybridPayloadEncryptor(
        publicKeyPem: keys.spkiPem,
        rsaPadding: RsaPadding.oaepSha256,
        aesKeyFormat: AesKeyFormat.rawBytes,
        aesKeyBits: 256,
      ).encrypt(body) as Map<String, dynamic>;
      expect(
        _decrypt(env, keys.priv,
            rsa: OAEPEncoding.withSHA256(RSAEngine()), hexKey: false),
        body,
      );
    });

    test('invalid key throws encryptionFailed', () {
      expect(
        () => HybridPayloadEncryptor(publicKeyPem: 'not a key'),
        throwsA(isA<APIError>()
            .having((e) => e.type, 'type', APIErrorType.encryptionFailed)),
      );
    });
  });

  group('request integration', () {
    Future<dynamic> sentBody(_Post target) async {
      final req = await target.createRequest() as http.Request;
      return jsonDecode(req.body);
    }

    test('encrypts non-GET bodies when enabled', () async {
      NetworkConfig.configure(
        payloadEncryptor: HybridPayloadEncryptor(publicKeyPem: keys.spkiPem),
      );
      final sent = await sentBody(_Post());
      expect(sent.keys, containsAll(['data', 'iv', 'key']));
      expect(_decrypt(sent, keys.priv), {'email': 'a@b.c'});
    });

    test(
        'plain JSON when the switch is off, no encryptor, or endpoint opts out',
        () async {
      expect(await sentBody(_Post()), {'email': 'a@b.c'});

      NetworkConfig.configure(
        payloadEncryptor: HybridPayloadEncryptor(publicKeyPem: keys.spkiPem),
        isPayloadEncryptionEnabled: false,
      );
      expect(await sentBody(_Post()), {'email': 'a@b.c'});

      NetworkConfig.configure(isPayloadEncryptionEnabled: true);
      expect(await sentBody(_Post(optOut: true)), {'email': 'a@b.c'});
    });

    test('GET query strings are encrypted only when opted in', () async {
      NetworkConfig.configure(
        payloadEncryptor: HybridPayloadEncryptor(publicKeyPem: keys.spkiPem),
      );
      final plain = _Post(
        method: HTTPMethod.get,
        task: RequestTask.parameters({'page': 1}),
      );
      expect((await plain.createRequest()).url.queryParameters, {'page': '1'});

      NetworkConfig.configure(encryptQueryParameters: true);
      final q = (await plain.createRequest()).url.queryParameters;
      expect(q.keys, containsAll(['data', 'iv', 'key']));
      expect(_decrypt(q, keys.priv), {'page': 1});
    });
  });
}
