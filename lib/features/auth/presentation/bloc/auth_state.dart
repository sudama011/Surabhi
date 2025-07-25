// lib/features/auth/presentation/bloc/auth_state.dart
part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {} // Initial state before any action

class AuthLoading extends AuthState {} // For showing progress indicators

class AuthAuthenticated extends AuthState {
  final UserModel user; // Full user details
  final String role; // User's role for routing

  const AuthAuthenticated({required this.user, required this.role});

  @override
  List<Object> get props => [user, role];
}

class AuthUnauthenticated extends AuthState {} // User is not logged in

class AuthRegistrationSuccess extends AuthState {} // Registration completed successfully

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}