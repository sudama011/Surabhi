// lib/core/constants/app_constants.dart
class AppConstants {
  static const String BASE_URL = 'http://127.0.0.1:5000/api';
  static const String LOGIN_ENDPOINT = '$BASE_URL/auth/login';
  static const String REGISTER_ENDPOINT = '$BASE_URL/auth/register';
  static const String PROFILE_ENDPOINT = '$BASE_URL/user/profile';
  static const String REFRESH_ENDPOINT = '$BASE_URL/auth/refresh';

  // Keys for secure storage
  static const String ACCESS_TOKEN_KEY = 'accessToken';
  static const String REFRESH_TOKEN_KEY = 'refreshToken';
  static const String USER_ROLE_KEY = 'userRole';

  static const List<String> ROLES = [
    'admin',
    'employee',
    'preacher',
    'approver',
    'volunteer'
  ];

  static final RegExp EMAIL_REGEX = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  static final RegExp PASSWORD_REGEX = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$'); // At least 8 characters, at least one letter and one number
}