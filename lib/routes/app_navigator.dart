// lib/routes/app_navigator.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/constants/app_constants.dart';

class AppNavigator {
  AppNavigator._();

  static void navigateBasedOnRole(BuildContext context, Role role) {
    String path;
    switch (role) {
      case Role.admin:
        path = '/admin-dashboard';
        break;
      case Role.employee:
        path = '/employee-dashboard';
        break;
      case Role.preacher:
        path = '/preacher-dashboard';
        break;
      case Role.approver:
        path = '/approver-dashboard';
        break;
      case Role.volunteer:
        path = '/volunteer-dashboard';
        break;
      case Role.social:
        path = '/social-dashboard';
        break;
    }
    context.go(path);
  }

  // Navigate to home (login/auth check)
  static void navigateToHome(BuildContext context, {bool checkAuthOnInit = true}) {
    context.go('/', extra: checkAuthOnInit);
  }

  // Navigate to settings
  static void navigateToSettings(BuildContext context) {
    context.push('/settings');
  }

  // Navigate to create user (admin only)
  static void navigateToCreateUser(BuildContext context) {
    context.push('/admin/create-user');
  }

  // Navigate back if possible, or to a default path
  static void navigateBackOrHome(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/'); // Or to a sensible default if no previous page
    }
  }
}
