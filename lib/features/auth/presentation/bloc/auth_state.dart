// lib/features/auth/presentation/bloc/auth_state.

part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthBiometricAvailable extends AuthState {
  final bool isAvailable;
  const AuthBiometricAvailable(this.isAvailable);
}

class AuthAuthenticated extends AuthState {
  final UserModel user;

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

// --- 2FA States ---

class Auth2FARequired extends AuthState {
  final List<TwoFAProvider> providers;

  const Auth2FARequired({required this.providers});

  @override
  List<Object> get props => [providers];
}

class Auth2FALoading extends AuthState {}

class Auth2FAOTPSent extends AuthState {
  final TwoFAProvider provider;
  final String message;

  const Auth2FAOTPSent({required this.provider, required this.message});

  @override
  List<Object> get props => [provider, message];
}

class Auth2FAError extends AuthState {
  final String message;

  const Auth2FAError({required this.message});

  @override
  List<Object> get props => [message];
}

class TwoFactorRequiredFailure extends Failure {
  final List<TwoFAProvider> providers;
  final String preAuthRefreshToken;

  const TwoFactorRequiredFailure({required this.providers, required this.preAuthRefreshToken})
    : super(message: '2FA Required');
}

class AuthBiometricLoading extends AuthState {}

class AuthBiometricFailure extends AuthState {
  final String message;

  const AuthBiometricFailure({required this.message});

  @override
  List<Object> get props => [message];
}
