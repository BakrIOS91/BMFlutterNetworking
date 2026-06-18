class ValidationHelper {

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?",
    );
    return emailRegex.hasMatch(email.trim().toLowerCase());
  }

  static bool isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^01[0125][0-9]{8}$');
    return phoneRegex.hasMatch(phone.trim());
  }

  static bool isValidName(String name) {
    return name.trim().length >= 3;
  }
}
