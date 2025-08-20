// lib/features/volunteer/dashboard/presentation/pages/volunteer_dashboard.dart

import 'package:flutter/material.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

class VolunteerDashboard extends StatelessWidget {
  const VolunteerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Volunteer Dashboard',
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volunteer_activism, size: 64, color: Colors.purple),
            SizedBox(height: 16),
            Text(
              'Welcome to Volunteer Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Volunteer features coming soon...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
