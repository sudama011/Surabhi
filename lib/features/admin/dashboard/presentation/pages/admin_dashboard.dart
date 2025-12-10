// lib/features/admin/dashboard/presentation/pages/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/domain/entities/navigation_item.dart';
import 'package:surabhi/core/widgets/app_shell.dart';
import 'package:surabhi/features/admin/users/presentation/bloc/users_bloc.dart' as admin_users;
import 'package:surabhi/features/admin/users/presentation/pages/users_list_page.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/injector.dart' as di;

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    const NavigationItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home', route: '/admin-dashboard'),
    const NavigationItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'Users',
      route: '/admin-dashboard/users',
    ),
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
      icon: Icons.assessment_outlined,
      selectedIcon: Icons.assessment,
      label: 'Reports',
      route: '/admin-dashboard/reports',
    ),
  ];

  void _onNavigationSelected(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _buildContent() {
    switch (_currentIndex) {
      case 0:
        return const Center(child: Text('Welcome to Admin Dashboard'));
      case 1:
        return BlocProvider(
          create: (context) => di.sl<admin_users.UsersBloc>()..add(const admin_users.GetUsersEvent(page: 1, size: 100)),
          child: const UsersListPage(),
        );
      case 2:
        return const Center(child: Text('Donors coming soon'));
      case 3:
        return const Center(child: Text('Donate coming soon'));
      case 4:
        return const Center(child: Text('Reports coming soon'));
      default:
        return const Center(child: Text('Welcome to Admin Dashboard'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        return AppShell(
          pageTitle: 'Admin Dashboard',
          items: _navigationItems,
          currentIndex: _currentIndex,
          onDestinationSelected: _onNavigationSelected,
          child: _buildContent(),
        );
      },
    );
  }
}
