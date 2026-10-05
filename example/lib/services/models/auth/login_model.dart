class Login {
  final String? accessToken;
  final String? refreshToken;

  Login({
    this.accessToken,
    this.refreshToken,
  });

  factory Login.fromJson(Map<String, dynamic> json) => Login(
        accessToken: json["access_token"],
        refreshToken: json["refresh_token"],
      );

  Map<String, dynamic> toJson() => {
        "access_token": accessToken,
        "refresh_token": refreshToken,
      };

  static Login mock = Login(
    accessToken: "access_token",
    refreshToken: "refresh_token",
  );
}
