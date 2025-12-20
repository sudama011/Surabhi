// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  static const String appName = 'Surabhi';
  static const String appVersion = '1.0.0';
  static const String appAuthor = 'Surabhi Team';

  // Breakpoints for responsive design
  static const double mobile = 600;
  static const double tablet = 1100;

  // session timeout constants
  static const sessionDuration = Duration(minutes: 15);
  static const warningDuration = Duration(minutes: 3);
}

enum Role { admin, employee, preacher, approver, volunteer, social }

enum AppTheme { light, dark, system }
