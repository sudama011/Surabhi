// lib/routes/app_router.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import 'package:surabhi/features/admin/users/presentation/bloc/users_bloc.dart';
import 'package:surabhi/features/admin/devotees/presentation/bloc/devotees_bloc.dart';
import 'package:surabhi/features/donors/presentation/bloc/donors_bloc.dart';
import 'package:surabhi/features/donors/presentation/pages/donors_page.dart';
import 'package:surabhi/routes/app_navigator.dart';
import 'package:surabhi/routes/app_routes.dart';
import 'package:surabhi/injector.dart' as di;

import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/core/models/navigation_item.dart';
import 'package:surabhi/core/services/session_timeout_manager.dart';
import 'package:surabhi/core/widgets/app_shell.dart';
import 'package:surabhi/core/widgets/error_display.dart';

import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/features/auth/presentation/pages/login_page.dart';
import 'package:surabhi/features/settings/presentation/pages/settings_page.dart';
import 'package:surabhi/features/profile/presentation/pages/profile_page.dart';

import 'package:surabhi/features/admin/home/presentation/pages/home_page.dart' as admin_dashboard;
import 'package:surabhi/features/admin/users/presentation/pages/create_user_page.dart' as admin_dashboard;
import 'package:surabhi/features/admin/users/presentation/pages/users_list_page.dart' as admin_dashboard;
import 'package:surabhi/features/admin/users/presentation/pages/user_details_page.dart' as admin_dashboard;
import 'package:surabhi/features/admin/devotees/presentation/pages/devotees_page.dart' as admin_dashboard;

import 'package:surabhi/features/employee/home/presentation/pages/home_page.dart' as employee_dashboard;
import 'package:surabhi/features/preacher/home/presentation/pages/home_page.dart' as preacher_dashboard;
import 'package:surabhi/features/approver/home/presentation/pages/home_page.dart' as approver_dashboard;
import 'package:surabhi/features/volunteer/home/presentation/pages/home_page.dart' as volunteer_dashboard;
import 'package:surabhi/features/social/home/presentation/pages/home_page.dart' as social_dashboard;

class AppRouter {
  final AuthBloc authBloc;
  final AppNavigator appNavigator;

  AppRouter(this.authBloc, this.appNavigator);

  late final GoRouter router = GoRouter(
    navigatorKey: appNavigator.navigatorKey,
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),

    routes: [
      // --- Public Routes ---
      GoRoute(path: AppRoutes.login, name: 'SignIn', builder: (context, state) => const LoginPage()),

      // --- Authenticated Shell ---
      ShellRoute(
        builder: (context, state, child) {
          final authState = authBloc.state;
          if (authState is AuthAuthenticated) {
            final user = authState.user;
            return AppShell(
              sideNavigationItems: _getSideNavItems(user.role),
              bottomNavigationitems: _getBottomNavItems(user.role),
              child: SessionTimeoutManager(child: child),
            );
          }
          return const LoginPage();
        },
        routes: [
          // 1. Global Pages
          GoRoute(
            path: AppRoutes.settings,
            name: 'Settings',
            pageBuilder: (context, state) => const NoTransitionPage(child: SettingsPage()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'Profile',
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage()),
          ),

          // 2. Admin Dashboard & Sub-routes
          GoRoute(
            path: AppRoutes.adminDashboard,
            name: 'AdminDashboard',
            pageBuilder: (context, state) => const NoTransitionPage(child: admin_dashboard.HomePage()),

            routes: [
              GoRoute(
                path: 'users',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: BlocProvider(
                    create: (context) => di.sl<UsersBloc>(),
                    child: const admin_dashboard.UsersListPage(),
                  ),
                ),
                routes: [
                  GoRoute(
                    path: ':userId',
                    pageBuilder: (context, state) {
                      final userId = state.pathParameters['userId'] ?? '';
                      return NoTransitionPage(
                        child: BlocProvider.value(
                          value: di.sl<UsersBloc>(),
                          child: admin_dashboard.UserDetailsPage(userId: userId),
                        ),
                      );
                    },
                  ),
                ],
              ),
              GoRoute(
                path: 'register-user',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: BlocProvider(
                    create: (context) => di.sl<UsersBloc>(),
                    child: const admin_dashboard.CreateUserPage(),
                  ),
                ),
              ),
              GoRoute(
                path: 'devotees',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: BlocProvider(
                    create: (context) => di.sl<DevoteesBloc>()..add(const GetDevoteesEvent()),
                    child: const admin_dashboard.DevoteesPage(),
                  ),
                ),
              ),
              GoRoute(
                path: 'donors',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: BlocProvider(create: (context) => di.sl<DonorsBloc>(), child: const DonorsPage()),
                ),
              ),
              GoRoute(
                path: 'donate',
                pageBuilder: (context, state) => const NoTransitionPage(child: Center(child: Text('Donate Page'))),
              ),
              GoRoute(
                path: 'donations',
                pageBuilder: (context, state) => const NoTransitionPage(child: Center(child: Text('Donations Page'))),
              ),
              GoRoute(
                path: 'reports',
                pageBuilder: (context, state) => const NoTransitionPage(child: Center(child: Text('Reports Page'))),
              ),
            ],
          ),

          GoRoute(
            path: AppRoutes.employeeDashboard,
            name: 'EmployeeDashboard',
            builder: (context, state) => const employee_dashboard.HomePage(),
            routes: [
              GoRoute(
                path: 'my-tasks',
                builder: (context, state) => const Center(child: Text('My Tasks Page')),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.preacherDashboard,
            name: 'PreacherDashboard',
            builder: (context, state) => const preacher_dashboard.HomePage(),
            routes: [
              GoRoute(
                path: 'sermons',
                builder: (context, state) => const Center(child: Text('Sermons Page')),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.approverDashboard,
            name: 'ApproverDashboard',
            builder: (context, state) => const approver_dashboard.HomePage(),
            routes: [
              GoRoute(
                path: 'approvals',
                builder: (context, state) => const Center(child: Text('Approvals Page')),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.volunteerDashboard,
            name: 'VolunteerDashboard',
            builder: (context, state) => const volunteer_dashboard.HomePage(),
            routes: [
              GoRoute(
                path: 'activities',
                builder: (context, state) => const Center(child: Text('Activities Page')),
              ),
            ],
          ),

          GoRoute(
            path: AppRoutes.socialDashboard,
            name: 'SocialDashboard',
            builder: (context, state) => const social_dashboard.HomePage(),
            routes: [
              GoRoute(
                path: 'connect',
                builder: (context, state) => const Center(child: Text('Connect Page')),
              ),
            ],
          ),
        ],
      ),
    ],

    redirect: (context, state) {
      final authState = authBloc.state;
      final targetRoute = state.matchedLocation; // Where the user is trying to go
      final isLoggingIn = targetRoute == AppRoutes.login;

      // 1. Initial/Loading -> Stay put
      if (authState is AuthLoading || authState is AuthInitial || authState is Auth2FARequired) {
        return null;
      }

      // 2. Unauthenticated -> Kick to Login
      if (authState is AuthUnauthenticated) {
        return isLoggingIn ? null : AppRoutes.login;
      }

      // 3. Authenticated -> Role Guards
      if (authState is AuthAuthenticated) {
        final user = authState.user;

        // A. Prevent going back to Login page
        if (isLoggingIn) {
          return _getDashboardRoute(user.role);
        }

        // B. SECURITY: Prevent Accessing Wrong Dashboards
        // If I am NOT Admin, but trying to access '/admin-dashboard...' -> Block me!
        if (user.role != Role.admin && targetRoute.startsWith(AppRoutes.adminDashboard)) {
          return _getDashboardRoute(user.role); // Bounce back to my own home
        }

        if (user.role != Role.employee && targetRoute.startsWith(AppRoutes.employeeDashboard)) {
          return _getDashboardRoute(user.role);
        }

        if (user.role != Role.preacher && targetRoute.startsWith(AppRoutes.preacherDashboard)) {
          return _getDashboardRoute(user.role);
        }

        // ... Add blocks for other roles as needed ...

        // C. Allow access to shared routes (Profile, Settings)
        // No check needed here, let them pass.
      }

      return null; // Allow navigation
    },

    errorBuilder: (context, state) => Scaffold(
      body: ErrorDisplay(message: 'Page not found: ${state.uri.path}', onRetry: () => context.go(AppRoutes.login)),
    ),
  );
}

// --- Navigation Helpers ---

List<NavigationItem> _getSideNavItems(Role role) {
  switch (role) {
    case Role.admin:
      return [
        const NavigationItem(
          icon: Icons.people_outlined,
          selectedIcon: Icons.people,
          label: 'Registered Users',
          route: AppRoutes.adminUsers,
        ),
        const NavigationItem(
          icon: Icons.person_add_outlined,
          selectedIcon: Icons.person_add,
          label: 'Add User',
          route: AppRoutes.adminCreateUser,
        ),
        const NavigationItem(
          icon: Icons.groups_outlined,
          selectedIcon: Icons.groups,
          label: 'Devotees',
          route: AppRoutes.adminDevotees,
        ),
      ];
    default:
      return [];
  }
}

List<NavigationItem> _getBottomNavItems(Role role) {
  switch (role) {
    case Role.admin:
      return [
        const NavigationItem(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: 'Home',
          route: AppRoutes.adminDashboard,
        ),
        const NavigationItem(
          icon: Icons.favorite_outline,
          selectedIcon: Icons.favorite,
          label: 'Donors',
          route: '${AppRoutes.adminDashboard}/donors',
        ),
        const NavigationItem(
          icon: Icons.volunteer_activism_outlined,
          selectedIcon: Icons.volunteer_activism,
          label: 'Donate',
          route: '${AppRoutes.adminDashboard}/donate',
        ),
        const NavigationItem(
          icon: Icons.account_balance_wallet_outlined,
          selectedIcon: Icons.account_balance_wallet,
          label: 'Donations',
          route: '${AppRoutes.adminDashboard}/donations',
        ),
        const NavigationItem(
          icon: Icons.assessment_outlined,
          selectedIcon: Icons.assessment,
          label: 'Reports',
          route: '${AppRoutes.adminDashboard}/reports',
        ),
      ];
    case Role.employee:
      return [
        const NavigationItem(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: 'Home',
          route: AppRoutes.employeeDashboard,
        ),
        const NavigationItem(
          icon: Icons.task_outlined,
          selectedIcon: Icons.task,
          label: 'My Tasks',
          route: '${AppRoutes.employeeDashboard}/my-tasks',
        ),
      ];
    case Role.preacher:
      return [
        const NavigationItem(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: 'Home',
          route: AppRoutes.preacherDashboard,
        ),
        const NavigationItem(
          icon: Icons.school_outlined,
          selectedIcon: Icons.school,
          label: 'Sermons',
          route: '${AppRoutes.preacherDashboard}/sermons',
        ),
      ];
    case Role.approver:
      return [
        const NavigationItem(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: 'Home',
          route: AppRoutes.approverDashboard,
        ),
        const NavigationItem(
          icon: Icons.check_circle_outlined,
          selectedIcon: Icons.check_circle,
          label: 'Approvals',
          route: '${AppRoutes.approverDashboard}/approvals',
        ),
      ];
    case Role.volunteer:
      return [
        const NavigationItem(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: 'Home',
          route: AppRoutes.volunteerDashboard,
        ),
        const NavigationItem(
          icon: Icons.volunteer_activism_outlined,
          selectedIcon: Icons.volunteer_activism,
          label: 'Activities',
          route: '${AppRoutes.volunteerDashboard}/activities',
        ),
      ];
    case Role.social:
      return [
        const NavigationItem(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: 'Home',
          route: AppRoutes.socialDashboard,
        ),
        const NavigationItem(
          icon: Icons.people_outlined,
          selectedIcon: Icons.people,
          label: 'Connect',
          route: '${AppRoutes.socialDashboard}/connect',
        ),
      ];
  }
}

String _getDashboardRoute(Role role) {
  switch (role) {
    case Role.admin:
      return AppRoutes.adminDashboard;
    case Role.employee:
      return AppRoutes.employeeDashboard;
    case Role.preacher:
      return AppRoutes.preacherDashboard;
    case Role.approver:
      return AppRoutes.approverDashboard;
    case Role.volunteer:
      return AppRoutes.volunteerDashboard;
    case Role.social:
      return AppRoutes.socialDashboard;
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (_) {
        if (!_disposed) {
          notifyListeners();
        }
      },
      onError: (error) {
        // Log error but don't crash
        debugPrint('GoRouterRefreshStream error: $error');
      },
    );
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _subscription.cancel();
    super.dispose();
  }
}
