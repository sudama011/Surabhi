// lib/features/dashboard/presentation/pages/approver_dashboard.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

class ApproverDashboard extends StatelessWidget {
  const ApproverDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Approver Dashboard',
      body: Center(child: Text('Approver Dashboard')),
    );
  }
}
