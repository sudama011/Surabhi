// lib/features/auth/presentation/bloc/auth_event.dart
part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {} // Event to check authentication status when app starts

class LoginButtonPressed extends AuthEvent {
  final String email;
  final String password;

  const LoginButtonPressed({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterButtonPressed extends AuthEvent {
  final String email;
  final String password;
  final String role; // Role for the new user

  const RegisterButtonPressed({required this.email, required this.password, required this.role});

  @override
  List<Object> get props => [email, password, role];
}

class LogoutButtonPressed extends AuthEvent {}