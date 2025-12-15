// lib/features/auth/presentation/widgets/auth_page_layout.dart

import 'package:flutter/material.dart';
import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/core/theme/app_colors.dart';
import 'package:surabhi/features/auth/presentation/widgets/upcoming_events_list.dart';

class AuthPageLayout extends StatelessWidget {
  final Widget child;

  const AuthPageLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Check if keyboard is open to hide bottom events
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // --- 1. Common Header (Welcome) ---
                    _buildHeader(context),

                    const SizedBox(height: 40),

                    // --- 2. Dynamic Content (Login/2FA) ---
                    child,
                  ],
                ),
              ),
            ),
          ),

          // --- 3. Bottom Events (Hidden when keyboard up) ---
          if (!isKeyboardOpen) const UpcomingEventsList(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Placeholder for Logo if you have one
        // Image.asset('assets/logo.png', height: 80),
        // const SizedBox(height: 16),
        Text(
          'Welcome to ${AppConstants.appName}',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryColor),
        ),
      ],
    );
  }
}
