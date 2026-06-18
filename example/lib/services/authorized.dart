import 'package:flutter_example/core/env/env.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

import 'package:flutter_example/core/dependency_injector/dependency_injector.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';

mixin Authorized on TargetRequest {
  final AppPreferences _pref = getIt();

  @override
  bool get isAuthorized => true;

  @override
  Map<String, String> get headers => {
        "apiKey": Env.apiKey,
      };

  @override
  Map<String, String> get authHeaders {
    final token = _pref.userAccessTokens?.accessToken;

    if (token == null || token.isEmpty) {
      return {};
    }

    return {
      "Authorization": "Bearer $token",
    };
  }
}
