abstract final class Validators {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  static bool isValidPhone(String digits) =>
      RegExp(r'^\d{10}$').hasMatch(digits);

  static bool isValidEmail(String email) => _email.hasMatch(email.trim());

  static bool isValidPassword(String password) => password.length >= 8;

  static bool isValidOtp(String otp) => RegExp(r'^\d{6}$').hasMatch(otp);

  static bool isValidName(String name) {
    final length = name.trim().length;
    return length >= 2 && length <= 100;
  }

  /// `yokesh@gmail.com` → `y•••@gmail.com`
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].isEmpty) return email;
    return '${parts[0][0]}•••@${parts[1]}';
  }
}
