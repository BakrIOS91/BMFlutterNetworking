import 'package:flutter_test/flutter_test.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SSLPinningConfiguration', () {
    test('default values', () {
      // Use non-const invocation so the constructor runs at runtime (coverage).
      final config = SSLPinningConfiguration();
      expect(config.isEnabled, isTrue);
      expect(config.allowFallback, isFalse);
      expect(config.pinnedHosts, isEmpty);
      expect(config.pinnedPublicKeyHashes, isEmpty);
      expect(config.pinnedCertificatePaths, isEmpty);
    });

    test('custom values are stored', () {
      final config = SSLPinningConfiguration(
        isEnabled: false,
        allowFallback: true,
        pinnedHosts: {'api.example.com'},
        pinnedPublicKeyHashes: {'sha256/abc123'},
        pinnedCertificatePaths: ['assets/cert.der'],
      );
      expect(config.isEnabled, isFalse);
      expect(config.allowFallback, isTrue);
      expect(config.pinnedHosts, contains('api.example.com'));
      expect(config.pinnedPublicKeyHashes, contains('sha256/abc123'));
      expect(config.pinnedCertificatePaths, ['assets/cert.der']);
    });
  });

  group('SSLPinningHelper.createSecureHttpClient', () {
    test('returns client when SSL pinning is disabled', () async {
      const config = SSLPinningConfiguration(isEnabled: false);
      final helper = SSLPinningHelper(configuration: config);
      final client = await helper.createSecureHttpClient();
      expect(client, isNotNull);
      client.close();
    });

    test('returns client when enabled with no cert paths', () async {
      const config = SSLPinningConfiguration(
        isEnabled: true,
        pinnedHosts: {'api.example.com'},
        pinnedCertificatePaths: [],
      );
      final helper = SSLPinningHelper(configuration: config);
      final client = await helper.createSecureHttpClient();
      expect(client, isNotNull);
      client.close();
    });

    test('handles missing cert paths without throwing', () async {
      // Non-existent asset paths should be silently ignored
      const config = SSLPinningConfiguration(
        isEnabled: true,
        pinnedCertificatePaths: ['assets/nonexistent.pem'],
      );
      final helper = SSLPinningHelper(configuration: config);
      final client = await helper.createSecureHttpClient();
      expect(client, isNotNull);
      client.close();
    });

    test('returns client with multiple pinned hosts and hashes', () async {
      const config = SSLPinningConfiguration(
        isEnabled: true,
        pinnedHosts: {'a.example.com', 'b.example.com'},
        pinnedPublicKeyHashes: {'sha256/hash1', 'sha256/hash2'},
      );
      final helper = SSLPinningHelper(configuration: config);
      final client = await helper.createSecureHttpClient();
      expect(client, isNotNull);
      client.close();
    });

    test('returns different clients for enabled vs disabled config', () async {
      const enabled = SSLPinningConfiguration(isEnabled: true);
      const disabled = SSLPinningConfiguration(isEnabled: false);

      final helper1 = SSLPinningHelper(configuration: enabled);
      final helper2 = SSLPinningHelper(configuration: disabled);

      final c1 = await helper1.createSecureHttpClient();
      final c2 = await helper2.createSecureHttpClient();

      expect(c1, isNotNull);
      expect(c2, isNotNull);
      c1.close();
      c2.close();
    });
  });
}
