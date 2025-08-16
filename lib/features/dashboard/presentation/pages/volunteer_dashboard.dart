// lib/features/dashboard/presentation/pages/volunteer_dashboard.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

class VolunteerDashboard extends StatelessWidget {
  const VolunteerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Volunteer Dashboard',
      body: Center(child: Text('Volunteer Dashboard')),
    );
  }
}

