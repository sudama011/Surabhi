// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Common colors
  static const Color primaryColor = Color(0xFF4A148C);
  static const Color secondaryColor = Color(0xFF673AB7);
  static const Color accentColor = Color(0xFFFFC107);
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onAccent = Colors.black;
  static const Color errorColor = Colors.red;
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFFBC02D);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightOnBackground = Colors.black87;
  static const Color lightSurface = Colors.white;
  static const Color lightOnSurface = Colors.black87;
  static const Color lightBorderColor = Color(0xFFBDBDBD); // grey[400]
  static const Color lightFocusBorder = Colors.blue;
  static const Color lightButton = Colors.blue;
  static const Color lightOnButton = Colors.white;
  static const Color lightTextColor = Color(0xFF333333);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkOnBackground = Colors.white70;
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkOnSurface = Colors.white70;
  static const Color darkBorderColor = Color(0xFF424242); // grey[800]
  static const Color darkFocusBorder = Color(0xFF64B5F6); // lightBlue
  static const Color darkButton = Color(0xFF64B5F6);
  static const Color darkOnButton = Colors.black;
  static const Color darkTextColor = Colors.white;
}
