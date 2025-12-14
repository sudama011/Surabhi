// lib/core/constants/api_constants.dart

class ApiConstants {
  ApiConstants._();

  // static const String baseApiUrl = 'http://10.0.2.2:8000';
  static const String baseApiUrl = 'https://api.vhkmsurabhi.com';
  static const String apiVersionPath = '/api';

  // Account/Authentication Endpoints
  static const String registerPath = '/Account/register';
  static const String loginPath = '/Account/login';
  static const String refreshPath = '/Account/refresh';
  static const String logoutPath = '/Account/logout';
  static const String confirmEmailPath = '/Account/confirmEmail';
  static const String resendEmailPath = '/Account/resendConfirmationEmail';
  static const String forgotPasswordPath = '/Account/forgotPassword';
  static const String changePasswordPath = '/Account/change-password';
  static const String adminResetPasswordPath = '/Account/admin/reset-password';
  static const String adminRemoveUserPath = '/Account/admin/remove-user';
  static const String adminChangeRolePath = '/Account/admin/change-role';
  static const String adminChangeEmailPath = '/Account/admin/change-email';
  static const String send2FAPath = '/Account/twofactor/send';
  static const String verify2FAPath = '/Account/twofactor/verify';
  static const String userProfilePath = '/Account/profile';
  static const String uploadAvatarPath = '/Account/upload-avatar';

  // User Management Endpoints (Admin)
  static const String userListPath = '/Admin/registered-users';
  static const String devoteeListPath = '/Admin/devotees';
}
