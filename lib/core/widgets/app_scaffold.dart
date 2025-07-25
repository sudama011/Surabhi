// lib/core/widgets/app_scaffold.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/widgets/role_based_app_bar.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final VoidCallback? onLeadingPressed;

  const AppScaffold({
    super.key,
    required this.body,
    required this.title,
    this.actions,
    this.onLeadingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoleBasedAppBar(
        titleText: title,
        actions: actions ?? [], // Ensure actions is never null
        onLeadingPressed: onLeadingPressed,
      ),
      body: body,
    );
  }
}