// lib/features/dashboard/presentation/pages/employee_dashboard.dart

import 'package:flutter/material.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

class EmployeeDashboard extends StatelessWidget {
  const EmployeeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Employee Dashboard',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('Welcome to Employee Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Employee features coming soon...', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
