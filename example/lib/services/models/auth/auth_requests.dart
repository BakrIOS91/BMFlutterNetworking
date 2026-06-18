// MARK: - Request
class LoginRequest {
  final String? email;
  final String? password;

  LoginRequest({
    this.email,
    this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => LoginRequest(
        email: json["email"],
        password: json["password"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "password": password,
      };
}

class RefreshTokenRequest {
  String? refreshToken;

  RefreshTokenRequest({
    this.refreshToken,
  });

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      RefreshTokenRequest(
        refreshToken: json["refresh_token"],
      );

  Map<String, dynamic> toJson() => {
        "refresh_token": refreshToken,
      };
}

// MARK: - Update Profile
class UpdateProfileRequest {
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final String? gender;
  final String? birthdate;

  UpdateProfileRequest({
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.gender,
    this.birthdate,
  });

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      UpdateProfileRequest(
        fullName: json["full_name"],
        phone: json["phone"],
        avatarUrl: json["avatar_url"],
        gender: json["gender"],
        birthdate: json["birthdate"],
      );

  Map<String, dynamic> toJson() => {
        "full_name": fullName,
        "phone": phone,
        "avatar_url": avatarUrl,
        "gender": gender,
        "birthdate": birthdate,
      };
}
