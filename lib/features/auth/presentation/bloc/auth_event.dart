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

  const LoginRequested({required this.email, required this.password});
}

class LogoutRequested extends AuthEvent {}

class TwoFAMethodSelected extends AuthEvent {
  final String method; // 'email' or 'phone'

  const TwoFAMethodSelected({required this.method});

  @override
  List<Object> get props => [method];
}

class OTPVerificationRequested extends AuthEvent {
  final String otp;
  final String method;

  const OTPVerificationRequested({required this.otp, required this.method});

  @override
  List<Object> get props => [otp, method];
}
