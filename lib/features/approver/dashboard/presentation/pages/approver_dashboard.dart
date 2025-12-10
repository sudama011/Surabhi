// lib/features/approver/dashboard/presentation/pages/approver_dashboard.dart

import 'package:flutter/material.dart';
import 'package:surabhi/core/domain/entities/navigation_item.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_shell.dart';

class ApproverDashboard extends StatefulWidget {
  const ApproverDashboard({super.key});

  @override
  State<ApproverDashboard> createState() => _ApproverDashboardState();
}

class _ApproverDashboardState extends State<ApproverDashboard> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    const NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      route: '/approver-dashboard',
    ),
    const NavigationItem(
      icon: Icons.check_circle_outlined,
      selectedIcon: Icons.check_circle,
      label: 'Approvals',
      route: '/approver-dashboard/approvals',
    ),
  ];

  void _onNavigationSelected(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _buildContent() {
    switch (_currentIndex) {
      case 1:
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
    return AppShell(
      pageTitle: 'Approver Dashboard',
      items: _navigationItems,
      currentIndex: _currentIndex,
      onDestinationSelected: _onNavigationSelected,
      child: _buildContent(),
    );
  }
}
