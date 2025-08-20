// lib/features/preacher/dashboard/presentation/pages/preacher_dashboard.dart

import 'package:flutter/material.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

class PreacherDashboard extends StatelessWidget {
  const PreacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Preacher Dashboard',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text('Welcome to Preacher Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Preacher features coming soon...', style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
