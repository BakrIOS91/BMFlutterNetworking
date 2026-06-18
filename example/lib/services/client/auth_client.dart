import 'package:flutter_example/services/models/auth/auth_requests.dart';
import 'package:flutter_example/services/models/auth/login_model.dart';
import 'package:flutter_example/services/models/auth/profile_model.dart';
import 'package:injectable/injectable.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';

import 'package:flutter_example/services/requests/auth_requests.dart';

@LazySingleton()
class AuthClient {
  Future<Result<Login?, APIError>> login(LoginRequest request) =>
      AuthLogin(request).performResult();

  Future<Result<Login?, APIError>> refreshToken(RefreshTokenRequest request) =>
      AuthRefreshToken(request).performResult();

  Future<Result<Login?, APIError>> signUp(LoginRequest request) =>
      SignUp(request).performResult();

  Future<Result<Profile?, APIError>> getProfile() =>
      GetProfile().performResult();

  Future<Result<Profile?, APIError>> updateProfile(
          UpdateProfileRequest request) =>
      UpdateProfile(request).performResult();
}