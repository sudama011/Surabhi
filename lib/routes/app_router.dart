// lib/routes/app_router.dart

import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:surabhi/core/services/session_timeout_manager.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:surabhi/features/auth/presentation/pages/login_page.dart';
import 'package:surabhi/features/admin/dashboard/presentation/pages/admin_dashboard.dart';
import 'package:surabhi/features/employee/dashboard/presentation/pages/employee_dashboard.dart';
import 'package:surabhi/features/preacher/dashboard/presentation/pages/preacher_dashboard.dart';
import 'package:surabhi/features/approver/dashboard/presentation/pages/approver_dashboard.dart';
import 'package:surabhi/features/volunteer/dashboard/presentation/pages/volunteer_dashboard.dart';
import 'package:surabhi/features/profile/presentation/pages/profile_page.dart';
import 'package:surabhi/features/settings/presentation/pages/settings_page.dart';
import 'package:surabhi/routes/app_navigator.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,

    // Tell GoRouter to listen to the AuthBloc's stream for state changes
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    routes: [
      ShellRoute(
        builder: (context, state, child) {
          // This wraps every page with the Session Manager
          return SessionTimeoutManager(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'login',
            builder: (context, state) => LoginPage(checkAuthOnInit: state.extra as bool? ?? true),
          ),
          GoRoute(
            path: '/admin-dashboard',
            name: 'admin-dashboard',
            builder: (context, state) => const AdminDashboard(),
            routes: [
              GoRoute(path: 'donors', name: 'admin-donors', builder: (context, state) => const AdminDashboard()),
              GoRoute(path: 'donate', name: 'admin-donate', builder: (context, state) => const AdminDashboard()),
              GoRoute(path: 'donations', name: 'admin-donations', builder: (context, state) => const AdminDashboard()),
              GoRoute(path: 'reports', name: 'admin-reports', builder: (context, state) => const AdminDashboard()),
              GoRoute(
                path: 'users',
                name: 'admin-users',
                builder: (context, state) => const AdminDashboard(),
                routes: [
                  GoRoute(path: 'details', name: 'user-details', builder: (context, state) => const AdminDashboard()),
                ],
              ),
              GoRoute(path: 'devotees', name: 'devotees', builder: (context, state) => const AdminDashboard()),
              GoRoute(
                path: 'register-user',
                name: 'register-user',
                builder: (context, state) => const AdminDashboard(),
              ),
            ],
          ),
          GoRoute(
            path: '/employee-dashboard',
            name: 'employee-dashboard',
            builder: (context, state) => const EmployeeDashboard(),
          ),
          GoRoute(
            path: '/preacher-dashboard',
            name: 'preacher-dashboard',
            builder: (context, state) => const PreacherDashboard(),
          ),
          GoRoute(
            path: '/approver-dashboard',
            name: 'approver-dashboard',
            builder: (context, state) => const ApproverDashboard(),
          ),
          GoRoute(
            path: '/volunteer-dashboard',
            name: 'volunteer-dashboard',
            builder: (context, state) => const VolunteerDashboard(),
          ),
          GoRoute(path: '/profile', name: 'profile', builder: (context, state) => const ProfilePage()),
          GoRoute(path: '/settings', name: 'settings', builder: (context, state) => const SettingsPage()),
        ],
      ),
    ],
    redirect: (context, state) {
      final authState = authBloc.state;
      final isLoggingIn = state.matchedLocation == '/';

      if (authState is AuthLoading || authState is AuthInitial || authState is Auth2FARequired) {
        return null;
      }

      if (authState is AuthUnauthenticated) {
        return isLoggingIn ? null : '/';
      }

      if (authState is AuthAuthenticated) {
        if (isLoggingIn) {
          return AppNavigator.getDashboardPath(authState.user.role);
        }
      }
      return null;
    },
  );
}

// Helper class to listen to a stream and notify listeners
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription _subscription;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
