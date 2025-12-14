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
}

class LogoutRequested extends AuthEvent {}

class SendOTPRequested extends AuthEvent {
  final String method; // 'Email' or 'Phone'

  const SendOTPRequested({required this.method});

  @override
  List<Object> get props => [method];
}

class OTPVerificationRequested extends AuthEvent {
  final String otp;
  final String method; // 'Email' or 'Phone'
  final bool rememberMe;
  final String preAuthRefreshToken;

  const OTPVerificationRequested({required this.otp, required this.method, this.rememberMe = false, this.preAuthRefreshToken = ''});

  @override
  List<Object> get props => [otp, method];
}
