// lib/core/utils/validators.dart
import 'package:surabhi/core/constants/app_constants.dart';

class AppValidators {
  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!AppConstants.EMAIL_REGEX.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if(value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!AppConstants.PASSWORD_REGEX.hasMatch(value)) {
      return 'Password must contain at least 1 letter and 1 number';
    }
    return null;
  }

  static String? confirmPasswordValidator(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}