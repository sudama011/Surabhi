import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:surabhi/routes/app_routes.dart';

class AppNavigator {
  // 1. Create a GlobalKey. This acts as our "Remote Control" for the Navigator.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // 2. Helper to get context without needing it passed in
  BuildContext get _context => navigatorKey.currentContext!;

  // 3. Navigation Methods (Abstracting GoRouter)
  void go(String routeName, {Object? extra}) {
    _context.go(routeName, extra: extra);
  }

  void push(String routeName, {Object? extra}) {
    _context.push(routeName, extra: extra);
  }

  void pop<T extends Object?>([T? result]) {
    if (_context.canPop()) {
      _context.pop(result);
    }
  }

  // Example of a specific action (Cleaner usage in Bloc)
  void navigateToLogin() => go(AppRoutes.login);
}
