// lib/features/auth/presentation/bloc/auth_event.dart

part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AppStarted extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginRequested({required this.email, required this.password, this.rememberMe = false});

  @override
  List<Object> get props => [email, password, rememberMe];
}

class SendOTPRequested extends AuthEvent {
  final TwoFAProvider provider;

  const SendOTPRequested({required this.provider});

  @override
  List<Object> get props => [provider];
}

class OTPVerificationRequested extends AuthEvent {
  final String otp;
  const OTPVerificationRequested({required this.otp});

  @override
  List<Object> get props => [otp];
}

class BiometricLoginRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}
