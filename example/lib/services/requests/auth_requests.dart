import 'package:flutter_example/core/env/env.dart';
import 'package:flutter_example/services/models/auth/auth_requests.dart';
import 'package:flutter_example/services/models/auth/login_model.dart';
import 'package:flutter_example/services/models/auth/profile_model.dart';
import 'package:bm_flutter_networking/bm_flutter_networking.dart';
import 'package:flutter_example/services/authorized.dart';
import 'package:flutter_example/services/app_targets.dart';

final class AuthLogin extends ModelTargetType<Login?> {
  LoginRequest request;

  AuthLogin(this.request) : super(decoder: Login.fromJson);

  @override
  String get baseURL => AuthAppTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.post;

  @override
  String get requestPath => "token";

  @override
  Map<String, String> get headers => {
        "apiKey": Env.apiKey,
      };

  @override
  RequestTask get requestTask => RequestTask.parametersAndBody(
        {
          "grant_type": "password",
        },
        request,
      );
}

final class AuthRefreshToken extends ModelTargetType<Login?> {
  RefreshTokenRequest request;

  AuthRefreshToken(this.request) : super(decoder: Login.fromJson);

  @override
  String get baseURL => AuthAppTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.post;

  @override
  String get requestPath => "token";

  @override
  Map<String, String> get headers => {
        "apiKey": Env.apiKey,
      };

  @override
  RequestTask get requestTask => RequestTask.parametersAndBody(
        {
          "grant_type": "refresh_token",
        },
        request,
      );
}

final class SignUp extends ModelTargetType<Login?> {
  LoginRequest request;

  SignUp(this.request) : super(decoder: Login.fromJson);

  @override
  String get baseURL => AuthAppTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.post;

  @override
  String get requestPath => "signup";

  @override
  Map<String, String> get headers => {
        "apiKey": Env.apiKey,
      };

  @override
  RequestTask get requestTask => RequestTask.encodedBody(request);
}

final class GetProfile extends ModelTargetType<Profile?> with Authorized {
  GetProfile() : super(decoder: Profile.fromJson);

  @override
  String get baseURL => AppTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.get;

  @override
  String get requestPath => "rpc/get_my_profile";
}

final class UpdateProfile extends ModelTargetType<Profile?> with Authorized {
  UpdateProfileRequest request;

  UpdateProfile(this.request) : super(decoder: Profile.fromJson);

  @override
  String get baseURL => AppTarget().kBaseURL;

  @override
  HTTPMethod get requestMethod => HTTPMethod.post;

  @override
  String get requestPath => "rpc/update_my_profile";

  @override
  RequestTask get requestTask => RequestTask.encodedBody(request);
}
