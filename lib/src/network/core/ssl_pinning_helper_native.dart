import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/asn1.dart';

import 'ssl_pinning.dart';

/// Helper class to enforce SSL/TLS pinning for HttpClient on native platforms.
class SSLPinningHelper {
  final SSLPinningConfiguration configuration;
  final List<Uint8List> _preloadedCerts = [];

  SSLPinningHelper({required this.configuration});

  Future<HttpClient> createSecureHttpClient() async {
    final securityContext = await _buildSecurityContext();
    final client = HttpClient(context: securityContext);

    if (!configuration.isEnabled) return client;

    await _preloadCertificates();

    client.badCertificateCallback = (cert, host, port) {
      // badCertificateCallback is only invoked when OS-level TLS validation
      // has already failed. Non-pinned hosts must always be rejected here —
      // returning allowFallback would accept TLS-invalid certs for any host
      // not in pinnedHosts, which is a security bypass.
      if (!configuration.pinnedHosts.contains(host)) {
        return false;
      }

      try {
        if (_validateCertificateSync(cert.der)) return true;
        if (_validatePublicKey(cert)) return true;
      } catch (e) {
        log('SSLPinning: Validation error: $e', name: 'SSLPinningHelper');
      }

      // allowFallback only applies to pinned hosts where pinning validation
      // itself failed (e.g. cert rotation during development).
      return configuration.allowFallback;
    };

    return client;
  }

  Future<SecurityContext> _buildSecurityContext() async {
    final context = SecurityContext(withTrustedRoots: true);

    for (final certPath in configuration.pinnedCertificatePaths) {
      try {
        final certBytes = await rootBundle.load(certPath);
        context.setTrustedCertificatesBytes(certBytes.buffer.asUint8List());
      } catch (e) {
        log(
          'SSLPinning: Could not load certificate from $certPath: $e',
          name: 'SSLPinningHelper',
        );
      }
    }

    return context;
  }

  Future<void> _preloadCertificates() async {
    _preloadedCerts.clear();
    for (final path in configuration.pinnedCertificatePaths) {
      try {
        final data = await rootBundle.load(path);
        _preloadedCerts.add(data.buffer.asUint8List());
      } catch (_) {}
    }
  }

  bool _validateCertificateSync(Uint8List certDer) {
    for (final pinned in _preloadedCerts) {
      if (_listEquals(pinned, certDer)) return true;
    }
    return false;
  }

  bool _validatePublicKey(X509Certificate cert) {
    try {
      final parser = ASN1Parser(cert.der);
      final topLevelSeq = parser.nextObject() as ASN1Sequence;
      final tbsCertificateSeq = topLevelSeq.elements![0] as ASN1Sequence;
      final subjectPublicKeyInfo = tbsCertificateSeq.elements![6];
      final keyBytes = subjectPublicKeyInfo.encodedBytes;

      if (keyBytes == null) return false;

      final hash = sha256.convert(keyBytes).toString();
      final isPinned =
          configuration.pinnedPublicKeyHashes.contains('sha256/$hash');
      if (!isPinned) {
        log(
          'SSLPinning: Server public key hash not pinned: sha256/$hash',
          name: 'SSLPinningHelper',
        );
      }
      return isPinned;
    } catch (e, st) {
      log(
        'SSLPinning: Public key validation failed: $e\n$st',
        name: 'SSLPinningHelper',
      );
      return false;
    }
  }

  bool _listEquals(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
