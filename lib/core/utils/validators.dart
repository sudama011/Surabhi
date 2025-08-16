// lib/core/utils/validators.dart

class AppValidators {

  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  static final RegExp _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return _passwordRegex.hasMatch(password);
  }
}