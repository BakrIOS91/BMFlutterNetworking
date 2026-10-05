import 'package:flutter_example/services/models/auth/auth_requests.dart';
import 'package:injectable/injectable.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:flutter_example/core/preferences/app_preferences.dart';
import 'package:flutter_example/services/client/auth_client.dart';

@singleton
final class AppTokenRefreshHandler implements TokenRefreshHandler {
  final AppPreferences _pref;
  final AuthClient _authClient;

  AppTokenRefreshHandler(this._pref, this._authClient);

  @override
  Future<bool> refreshToken() async {
    bool isRefreshed = false;
    final refreshTokenRequest = RefreshTokenRequest(
      refreshToken: _pref.userAccessTokens?.refreshToken,
    );
    final result = await _authClient.refreshToken(refreshTokenRequest);
    result.when(
      success: (response) {
        if (response != null) {
          _pref.userAccessTokens = response;
          isRefreshed = true;
        } else {
          isRefreshed = false;
        }
      },
      failure: (_) {
        isRefreshed = false;
      },
    );
    return isRefreshed;
  }
}
