// lib/features/volunteer/dashboard/presentation/pages/volunteer_dashboard.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/domain/entities/navigation_item.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_shell.dart';

class VolunteerDashboard extends StatelessWidget {
  const VolunteerDashboard({super.key});

  final List<NavigationItem> _navigationItems = const [
    NavigationItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home', route: '/volunteer-dashboard'),
    NavigationItem(
      icon: Icons.volunteer_activism_outlined,
      selectedIcon: Icons.volunteer_activism,
      label: 'Activities',
      route: '/volunteer-dashboard/activities',
    ),
  ];

  void _onNavigationSelected(String route, BuildContext context) {
    context.go(route);
  }

  Widget _buildContent(String currentLocation, BuildContext context) {
    switch (currentLocation) {
      case '/volunteer-dashboard/activities':
        return const Center(child: Text('Activities coming soon'));
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.volunteer_activism, size: 64, color: AppColors.volunteerColor),
              const SizedBox(height: 16),
              const Text('Welcome to Volunteer Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Volunteer features coming soon...',
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
      pageTitle: 'Volunteer Dashboard',
      sideNavigationItems: _navigationItems,
      bottomNavigationitems: _navigationItems,
      onNavigationSelected: (route) => _onNavigationSelected(route, context),
      child: _buildContent(location, context),
    );
  }
}
