/// SSL/TLS Pinning Configuration for BMFlutter Networking Layer
library;

/// Configuration for SSL/TLS pinning security settings.
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
