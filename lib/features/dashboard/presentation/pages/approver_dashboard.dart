// lib/features/dashboard/presentation/pages/approver_dashboard.dart

import 'package:flutter/material.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

class ApproverDashboard extends StatelessWidget {
  const ApproverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Approver Dashboard',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('Welcome to Approver Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Approver features coming soon...', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
