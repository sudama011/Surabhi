// lib/routes/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/features/auth/presentation/pages/login_page.dart';
import 'package:surabhi/features/auth/presentation/pages/register_page.dart';
import 'package:surabhi/features/auth/presentation/pages/splash_screen.dart';

// import 'package:surabhi/features/home/presentation/pages/home_page.dart'; // Generic home

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true, // Helpful for debugging routing issues
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    // GoRoute(
    //   path: '/home', // Generic fallback home page
    //   name: 'home',
    //   builder: (context, state) => const HomePage(),
    // ),
    
   
  ],
  redirect: (context, state) {
    final authState = context.read<AuthBloc>().state;
    final bool isAuthenticated = authState is AuthAuthenticated;
    final bool isUnauthenticated = authState is AuthUnauthenticated;
    final bool isLoading = authState is AuthLoading || authState is AuthInitial;

    final String? loggedInRole = isAuthenticated ? authState.role : null;

    final String loginLocation = state.namedLocation('login');
    final bool isGoingToLoginOrRegister = state.fullPath == loginLocation || state.fullPath == '/register';

    // If app is still loading auth state, don't redirect yet
    if (isLoading) return null;

    // If not authenticated and not going to login/register, redirect to login
    if (isUnauthenticated && !isGoingToLoginOrRegister) {
      return loginLocation;
    }

    // If authenticated and trying to go to login/register, redirect to their dashboard
    if (isAuthenticated && isGoingToLoginOrRegister) {
      return _getDashboardPathForRole(loggedInRole);
    }

    return null; // No redirect needed
  },
);

String _getDashboardPathForRole(String? role) {
  switch (role) {
    case 'admin': return '/admin-dashboard';
    case 'employee': return '/employee-dashboard';
    case 'preacher': return '/preacher-dashboard';
    case 'approver': return '/approver-dashboard';
    case 'volunteer': return '/volunteer-dashboard';
    default: return '/home';
  }
}