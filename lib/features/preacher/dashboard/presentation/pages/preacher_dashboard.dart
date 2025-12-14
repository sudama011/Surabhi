// lib/features/preacher/dashboard/presentation/pages/preacher_dashboard.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/models/navigation_item.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_shell.dart';

class PreacherDashboard extends StatelessWidget {
  const PreacherDashboard({super.key});

  final List<NavigationItem> _navigationItems = const [
    NavigationItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home', route: '/preacher-dashboard'),
    NavigationItem(
      icon: Icons.school_outlined,
      selectedIcon: Icons.school,
      label: 'Sermons',
      route: '/preacher-dashboard/sermons',
    ),
  ];

  void _onNavigationSelected(String route, BuildContext context) {
    context.go(route);
  }

  Widget _buildContent(String currentLocation, BuildContext context) {
    switch (currentLocation) {
      case '/preacher-dashboard/sermons':
        return const Center(child: Text('Sermons coming soon'));
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.school, size: 64, color: AppColors.preacherColor),
              const SizedBox(height: 16),
              const Text('Welcome to Preacher Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Preacher features coming soon...',
                style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return AppShell(
      sideNavigationItems: _navigationItems,
      bottomNavigationitems: _navigationItems,
      onNavigationSelected: (route) => _onNavigationSelected(route, context),
      child: _buildContent(location, context),
    );
  }
}
