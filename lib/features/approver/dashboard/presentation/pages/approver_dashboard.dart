// lib/features/approver/dashboard/presentation/pages/approver_dashboard.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/core/models/navigation_item.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_shell.dart';

class ApproverDashboard extends StatelessWidget {
  const ApproverDashboard({super.key});

  final List<NavigationItem> _navigationItems = const [
    NavigationItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home', route: '/approver-dashboard'),
    NavigationItem(
      icon: Icons.check_circle_outlined,
      selectedIcon: Icons.check_circle,
      label: 'Approvals',
      route: '/approver-dashboard/approvals',
    ),
  ];

  void _onNavigationSelected(String route, BuildContext context) {
    context.go(route);
  }

  Widget _buildContent(String currentLocation, BuildContext context) {
    switch (currentLocation) {
      case '/approver-dashboard/approvals':
        return const Center(child: Text('Pending Approvals coming soon'));
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 64, color: AppColors.approverColor),
              const SizedBox(height: 16),
              const Text('Welcome to Approver Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Approver features coming soon...',
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
