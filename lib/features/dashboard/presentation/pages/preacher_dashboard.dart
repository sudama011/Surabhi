// lib/features/dashboard/presentation/pages/preacher_dashboard.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

class PreacherDashboard extends StatelessWidget {
  const PreacherDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Preacher Dashboard',
      body: Center(child: Text('Preacher Dashboard')),
    );
  }
}
