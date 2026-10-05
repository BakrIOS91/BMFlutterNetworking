import 'ssl_pinning.dart';

/// Web stub for SSLPinningHelper.
/// Browsers enforce certificate validation natively — custom pinning via
/// HttpClient is not available on web.
class SSLPinningHelper {
  final SSLPinningConfiguration configuration;

  SSLPinningHelper({required this.configuration});

  Future<Never> createSecureHttpClient() async {
    throw UnsupportedError(
      'SSLPinningHelper is not supported on web. '
      'Browsers handle certificate validation natively.',
    );
  }
}
