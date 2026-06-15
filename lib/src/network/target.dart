/// Network Target Configuration for BMFlutter Networking Layer
library;

import 'package:bm_flutter_networking/src/helpers/enums.dart';

/// Represents a target configuration for network requests
abstract class Target {
  AppEnvironment get appEnvironment => AppEnvironment.development;
  String get kAppHost;
  String? get kMainAPIPath => null;
  String? get kAppApiPath => null;
  String get kAppScheme;
  int? get kAppPort => null;

  String get sanitizedHost => kAppHost.replaceAll(RegExp(r'^/+|/+$'), '');

  Uri get kBaseURLComponents {
    final pathSegments = <String>[];
    if (kMainAPIPath != null && kMainAPIPath!.isNotEmpty) {
      pathSegments.add(kMainAPIPath!.replaceAll(RegExp(r'^/+|/+$'), ''));
    }
    if (kAppApiPath != null && kAppApiPath!.isNotEmpty) {
      pathSegments.add(kAppApiPath!.replaceAll(RegExp(r'^/+|/+$'), ''));
    }

    final combinedPath =
        pathSegments.isNotEmpty ? '/${pathSegments.join('/')}/' : '/';

    return Uri(
      scheme: kAppScheme,
      host: sanitizedHost,
      port: kAppPort,
      path: combinedPath,
    );
  }

  String get kBaseURL => kBaseURLComponents.toString();
}
