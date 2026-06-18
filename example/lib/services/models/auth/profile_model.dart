class Profile {
  final String? id;
  final String? email;
  final String? phone;
  final String? gender;
  final String? birthdate;
  final String? fullName;
  final String? avatarUrl;

  Profile({
    this.id,
    this.email,
    this.phone,
    this.gender,
    this.birthdate,
    this.fullName,
    this.avatarUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json["id"],
        email: json["email"],
        phone: json["phone"],
        gender: json["gender"],
        birthdate: json["birthdate"],
        fullName: json["full_name"],
        avatarUrl: json["avatar_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "email": email,
        "phone": phone,
        "gender": gender,
        "birthdate": birthdate,
        "full_name": fullName,
        "avatar_url": avatarUrl,
      };
}
