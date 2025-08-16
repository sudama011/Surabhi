// lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:surabhi/core/widgets/app_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Home',
      body: Center(child: Text('Welcome Home')),
    );
  }
}

