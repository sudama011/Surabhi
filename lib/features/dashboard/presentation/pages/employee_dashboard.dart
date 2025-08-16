// lib/features/dashboard/presentation/pages/employee_dashboard.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Employee Dashboard',
      body: Center(child: Text('Employee Dashboard')),
    );
  }
}
