// lib/features/admin/dashboard/presentation/pages/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/domain/entities/navigation_item.dart';
import 'package:surabhi/core/widgets/app_shell.dart';
import 'package:surabhi/features/admin/dashboard/presentation/pages/home_page.dart';
import 'package:surabhi/features/admin/users/presentation/bloc/users_bloc.dart' as admin_users;
import 'package:surabhi/features/admin/users/presentation/pages/users_list_page.dart';
import 'package:surabhi/features/admin/users/presentation/pages/create_user_page.dart';
import 'package:surabhi/features/admin/devotees/presentation/pages/devotees_page.dart';
import 'package:surabhi/features/admin/roles/presentation/cubit/roles_cubit.dart' as admin_roles;
import 'package:surabhi/features/admin/users/presentation/cubit/create_user_cubit.dart' as admin_users;
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/injector.dart' as di;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final List<NavigationItem> _bottomNavigationItems = [
    const NavigationItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home', route: '/admin-dashboard'),
    const NavigationItem(
      icon: Icons.favorite_outline,
      selectedIcon: Icons.favorite,
      label: 'Donors',
      route: '/admin-dashboard/donors',
    ),
    const NavigationItem(
      icon: Icons.volunteer_activism_outlined,
      selectedIcon: Icons.volunteer_activism,
      label: 'Donate',
      route: '/admin-dashboard/donate',
    ),
    const NavigationItem(
      icon: Icons.account_balance_wallet_outlined,
      selectedIcon: Icons.account_balance_wallet,
      label: 'Donations',
      route: '/admin-dashboard/donations',
    ),
    const NavigationItem(
      icon: Icons.assessment_outlined,
      selectedIcon: Icons.assessment,
      label: 'Reports',
      route: '/admin-dashboard/reports',
    ),
  ];

  final List<NavigationItem> _sideNavigationItems = [
    const NavigationItem(
      icon: Icons.people_outlined,
      selectedIcon: Icons.people,
      label: 'Registered Users',
      route: '/admin-dashboard/users',
    ),
    const NavigationItem(
      icon: Icons.person_add_outlined,
      selectedIcon: Icons.person_add,
      label: 'Add User',
      route: '/admin-dashboard/register-user',
    ),
    const NavigationItem(
      icon: Icons.groups_outlined,
      selectedIcon: Icons.groups,
      label: 'Devotees',
      route: '/admin-dashboard/devotees',
    ),
  ];

  void _onNavigationSelected(String route) {
    context.go(route);
  }

  Widget _buildContent(String currentLocation) {
    // Check sidebar routes first
    if (currentLocation == '/admin-dashboard/users') {
      return BlocProvider(
        create: (context) => di.sl<admin_users.UsersBloc>()..add(const admin_users.GetUsersEvent(page: 1, size: 100)),
        child: const UsersListPage(),
      );
    } else if (currentLocation == '/admin-dashboard/register-user') {
      return MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => di.sl<admin_roles.RolesCubit>()..fetchRoles()),
          BlocProvider(create: (context) => di.sl<admin_users.CreateUserCubit>()),
        ],
        child: const CreateUserPage(),
      );
    } else if (currentLocation == '/admin-dashboard/devotees') {
      return const DevoteesPage();
    }

    // Check bottom nav routes
    switch (currentLocation) {
      case '/admin-dashboard':
        return const HomePage();
      case '/admin-dashboard/donors':
        return const Center(child: Text('Donors coming soon'));
      case '/admin-dashboard/donate':
        return const Center(child: Text('Donate coming soon'));
      case '/admin-dashboard/donations':
        return const Center(child: Text('Donations coming soon'));
      case '/admin-dashboard/reports':
        return const Center(child: Text('Reports coming soon'));
      default:
        return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final location = GoRouterState.of(context).uri.path;

        return AppShell(
          sideNavigationItems: _sideNavigationItems,
          bottomNavigationitems: _bottomNavigationItems,
          onNavigationSelected: _onNavigationSelected,
          child: _buildContent(location),
        );
      },
    );
  }
}
