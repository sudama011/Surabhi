// lib/routes/app_routes.dart

class AppRoutes {
  AppRoutes._();

  // --- Core Routes ---
  static const String login = '/';
  static const String settings = '/settings';
  static const String profile = '/profile';
  static const String notFound = '/404';

  // --- Dashboards (Role Based) ---
  static const String adminDashboard = '/admin-dashboard';
  static const String employeeDashboard = '/employee-dashboard';
  static const String preacherDashboard = '/preacher-dashboard';
  static const String approverDashboard = '/approver-dashboard';
  static const String volunteerDashboard = '/volunteer-dashboard';
  static const String socialDashboard = '/social-dashboard';

  // --- Admin Sub-Routes ---
  static const String adminUsers = '$adminDashboard/users';
  static const String adminCreateUser = '$adminDashboard/register-user';
  static const String adminDevotees = '$adminDashboard/devotees';

  // Helper to build dynamic routes (e.g., /users/123)
  static String userDetails(String id) => '$adminUsers/$id';
}
