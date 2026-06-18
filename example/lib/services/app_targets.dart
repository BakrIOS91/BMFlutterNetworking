import 'package:bm_flutter_networking/bm_flutter_networking.dart';

import 'package:flutter_example/core/env/env.dart';

final AppEnvironment appEnv = AppEnvironment.development;

class AppTarget extends Target {
  @override
  AppEnvironment get appEnvironment => appEnv;

  @override
  String get kAppScheme {
    switch (appEnvironment) {
      default:
        return "https";
    }
  }

  @override
  String? get kMainAPIPath {
    switch (appEnvironment) {
      default:
        return Env.apiMainPath;
    }
  }

  @override
  String? get kAppApiPath {
    switch (appEnvironment) {
      default:
        return Env.apiPath;
    }
  }

  @override
  String get kAppHost {
    switch (appEnvironment) {
      default:
        return Env.baseUrl;
    }
  }
}

class AuthAppTarget extends Target {
  @override
  AppEnvironment get appEnvironment => appEnv;

  @override
  String get kAppScheme {
    switch (appEnvironment) {
      default:
        return "https";
    }
  }

  @override
  String? get kMainAPIPath {
    switch (appEnvironment) {
      default:
        return Env.apiAuthMainPath;
    }
  }

  @override
  String? get kAppApiPath {
    switch (appEnvironment) {
      default:
        return Env.apiPath;
    }
  }

  @override
  String get kAppHost {
    switch (appEnvironment) {
      default:
        return Env.baseUrl;
    }
  }
}
