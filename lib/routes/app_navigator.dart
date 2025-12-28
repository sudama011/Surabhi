import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/routes/app_routes.dart';

class AppNavigator {
  // 1. Create a GlobalKey. This acts as our "Remote Control" for the Navigator.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // 2. Helper to safely get context (returns null if not available)
  BuildContext? get _context => navigatorKey.currentContext;

  // 3. Check if navigator is ready
  bool get _isReady => navigatorKey.currentState != null && _context != null;

  // 4. Navigation Methods (Abstracting GoRouter)
  void go(String routeName, {Object? extra}) {
    final context = _context;
    if (context != null && context.mounted) {
      context.go(routeName, extra: extra);
    }
  }

  void push(String routeName, {Object? extra}) {
    final context = _context;
    if (context != null && context.mounted) {
      context.push(routeName, extra: extra);
    }
  }

  void pop<T extends Object?>([T? result]) {
    if (_isReady) {
      try {
        navigatorKey.currentState!.pop(result);
      } catch (e) {
        // Ignore if pop fails
      }
    }
  }

  // Specific action (Cleaner usage in Bloc)
  void navigateToLogin() => go(AppRoutes.login);
}
