// lib/routes/app_navigator.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/constants/app_constants.dart';

class AppNavigator {
  AppNavigator._();

  static String getDashboardPath(Role role) {
    switch (role) {
      case Role.admin:
        return '/admin-dashboard';
      case Role.employee:
        return '/employee-dashboard';
      case Role.preacher:
        return '/preacher-dashboard';
      case Role.approver:
        return '/approver-dashboard';
      case Role.volunteer:
        return '/volunteer-dashboard';
      case Role.social:
        return '/social-dashboard';
    }
  }

  static void navigateBasedOnRole(BuildContext context, Role role) {
    context.go(getDashboardPath(role));
  }
}
