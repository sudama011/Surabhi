// lib/features/preacher/dashboard/presentation/pages/preacher_dashboard.dart

import 'package:flutter/material.dart';
import 'package:surabhi/core/domain/entities/navigation_item.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_shell.dart';

class PreacherDashboard extends StatefulWidget {
  const PreacherDashboard({super.key});

  @override
  State<PreacherDashboard> createState() => _PreacherDashboardState();
}

class _PreacherDashboardState extends State<PreacherDashboard> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    const NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      route: '/preacher-dashboard',
    ),
    const NavigationItem(
      icon: Icons.school_outlined,
      selectedIcon: Icons.school,
      label: 'Sermons',
      route: '/preacher-dashboard/sermons',
    ),
  ];

  void _onNavigationSelected(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _buildContent() {
    switch (_currentIndex) {
      case 1:
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
    return AppShell(
      pageTitle: 'Preacher Dashboard',
      items: _navigationItems,
      currentIndex: _currentIndex,
      onDestinationSelected: _onNavigationSelected,
      child: _buildContent(),
    );
  }
}
