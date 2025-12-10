// lib/features/volunteer/dashboard/presentation/pages/volunteer_dashboard.dart

import 'package:flutter/material.dart';
import 'package:surabhi/core/domain/entities/navigation_item.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_shell.dart';

class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({super.key});

  @override
  State<VolunteerDashboard> createState() => _VolunteerDashboardState();
}

class _VolunteerDashboardState extends State<VolunteerDashboard> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    const NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      route: '/volunteer-dashboard',
    ),
    const NavigationItem(
      icon: Icons.volunteer_activism_outlined,
      selectedIcon: Icons.volunteer_activism,
      label: 'Activities',
      route: '/volunteer-dashboard/activities',
    ),
  ];

  void _onNavigationSelected(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _buildContent() {
    switch (_currentIndex) {
      case 1:
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
    return AppShell(
      pageTitle: 'Volunteer Dashboard',
      items: _navigationItems,
      currentIndex: _currentIndex,
      onDestinationSelected: _onNavigationSelected,
      child: _buildContent(),
    );
  }
}
