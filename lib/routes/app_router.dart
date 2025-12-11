// lib/routes/app_router.dart

import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

import 'package:surabhi/features/auth/presentation/pages/login_page.dart';
import 'package:surabhi/features/admin/dashboard/presentation/pages/admin_dashboard.dart';
import 'package:surabhi/features/employee/dashboard/presentation/pages/employee_dashboard.dart';
import 'package:surabhi/features/preacher/dashboard/presentation/pages/preacher_dashboard.dart';
import 'package:surabhi/features/approver/dashboard/presentation/pages/approver_dashboard.dart';
import 'package:surabhi/features/volunteer/dashboard/presentation/pages/volunteer_dashboard.dart';
import 'package:surabhi/features/profile/presentation/pages/profile_page.dart';
import 'package:surabhi/features/settings/presentation/pages/settings_page.dart';

// Create a custom ChangeNotifier to listen to the AuthBloc stream
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

// Your app's router
class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  GoRouter get router => _goRouter;
  late final GoRouter _goRouter = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: kDebugMode,
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
          GoRoute(path: 'users', name: 'admin-users', builder: (context, state) => const AdminDashboard(),
          routes: [
            GoRoute(path: 'details', name: 'user-details', builder: (context, state) => const AdminDashboard()),
          ],
          ),
         
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
    // Tell GoRouter to listen to the AuthBloc's stream for state changes
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state; // Access the bloc instance directly

      final bool isAuthenticated = authState is AuthAuthenticated;
      final bool isUnauthenticated = authState is AuthUnauthenticated;
      final bool isLoading = authState is AuthLoading || authState is AuthInitial;
      final bool is2FARequired = authState is Auth2FARequired;

      final String? loggedInRole = isAuthenticated ? (authState).user.role : null;

      const publicPaths = ['/'];
      final bool isGoingToPublicPath = publicPaths.contains(state.fullPath);
      final bool isOnHome = state.fullPath == '/';

      // 1. If still loading auth state, stay on home
      if (isLoading && !isOnHome) {
        return '/';
      }

      // 2. If 2FA is required, keep user on login page (2FA flow is handled within LoginPage)
      if (is2FARequired && !isOnHome) {
        return '/';
      }

      // 3. If unauthenticated: allow access to public paths, redirect protected routes to home
      if (isUnauthenticated) {
        if (!isGoingToPublicPath) {
          return '/'; // Redirect to home page
        }
      }

      // 4. If authenticated and trying to go to home, redirect to their dashboard
      if (isAuthenticated && isGoingToPublicPath) {
        return _getDashboardPathForRole(loggedInRole);
      }

      return null; // No redirect needed
    },
  );
}

String _getDashboardPathForRole(String? role) {
  switch (role) {
    case 'admin':
      return '/admin-dashboard';
    case 'employee':
      return '/employee-dashboard';
    case 'preacher':
      return '/preacher-dashboard';
    case 'approver':
      return '/approver-dashboard';
    case 'volunteer':
      return '/volunteer-dashboard';
    default:
      return '/admin-dashboard';
  }
}
