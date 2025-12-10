// lib/features/employee/dashboard/presentation/pages/employee_dashboard.dart

import 'package:flutter/material.dart';
import 'package:surabhi/core/domain/entities/navigation_item.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/core/widgets/app_shell.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    const NavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      route: '/employee-dashboard',
    ),
    const NavigationItem(
      icon: Icons.assignment_outlined,
      selectedIcon: Icons.assignment,
      label: 'My Tasks',
      route: '/employee-dashboard/tasks',
    ),
  ];

  void _onNavigationSelected(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _buildContent() {
    switch (_currentIndex) {
      case 1:
        return const Center(child: Text('My Tasks coming soon'));
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.work, size: 64, color: AppColors.employeeColor),
              const SizedBox(height: 16),
              const Text('Welcome to Employee Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Employee features coming soon...',
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
      pageTitle: 'Employee Dashboard',
      items: _navigationItems,
      currentIndex: _currentIndex,
      onDestinationSelected: _onNavigationSelected,
      child: _buildContent(),
    );
  }
}
