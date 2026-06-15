/// SSL/TLS Pinning for BMFlutter Networking Layer
library;

import 'dart:developer';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:pointycastle/asn1.dart';

/// Configuration for SSL/TLS pinning security settings
class SSLPinningConfiguration {
  final bool isEnabled;
  final bool allowFallback;
  final Set<String> pinnedHosts;
  final Set<String> pinnedPublicKeyHashes;
  final List<String> pinnedCertificatePaths;

  const SSLPinningConfiguration({
    this.isEnabled = true,
    this.allowFallback = false,
    this.pinnedHosts = const {},
    this.pinnedPublicKeyHashes = const {},
    this.pinnedCertificatePaths = const [],
  });
}

/// Helper class to enforce SSL/TLS pinning for HttpClient
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
      if (!configuration.pinnedHosts.contains(host)) {
        return configuration.allowFallback;
      }

      try {
        final certDer = cert.der;
        if (_validateCertificateSync(certDer)) return true;
        if (_validatePublicKey(cert)) return true;
      } catch (e) {
        log('SSLPinning: Validation error: $e', name: 'SSLPinningHelper');
      }

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
      } catch (_) {
        // Ignore loading errors
      }
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
      final derBytes = cert.der;
      final parser = ASN1Parser(derBytes);

      final topLevelSeq = parser.nextObject() as ASN1Sequence;
      final tbsCertificateSeq = topLevelSeq.elements![0] as ASN1Sequence;

      final subjectPublicKeyInfo = tbsCertificateSeq.elements![6];
      final keyBytes = subjectPublicKeyInfo.encodedBytes;

      if (keyBytes == null) return false;

      final hash = sha256.convert(keyBytes).toString();
      final formattedHash = 'sha256/$hash';

      final isPinned = configuration.pinnedPublicKeyHashes.contains(
        formattedHash,
      );
      if (!isPinned) {
        log(
          'SSLPinning: Server public key hash not pinned: $formattedHash',
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
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
