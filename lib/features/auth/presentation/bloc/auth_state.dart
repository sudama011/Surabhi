// lib/features/auth/presentation/bloc/auth_state.

part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  final String? message;

  const AuthUnauthenticated({this.message});
  @override
  List<Object> get props => [message ?? ''];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}

// 2FA States
class Auth2FARequired extends AuthState {
  final UserEntity user;

  const Auth2FARequired({required this.user});

  @override
  List<Object> get props => [user];
}

class Auth2FALoading extends AuthState {}

class Auth2FAOTPSent extends AuthState {
  final String method;
  final String message;

  const Auth2FAOTPSent({required this.method, required this.message});

  @override
  List<Object> get props => [method, message];
}

class Auth2FAError extends AuthState {
  final String message;

  const Auth2FAError({required this.message});

  @override
  List<Object> get props => [message];
}
