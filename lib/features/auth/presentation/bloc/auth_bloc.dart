// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/models/user_model.dart';
import 'package:surabhi/features/auth/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  // Store user temporarily during 2FA flow
  UserModel? _pendingUser;
  String? _pendingEmail;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<AppStarted>(_onAppStarted);
    on<LogoutRequested>(_onLogoutRequested);
    on<SendOTPRequested>(_onSendOTPRequested);
    on<OTPVerificationRequested>(_onOTPVerificationRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.login(event.email, event.password, event.rememberMe);
    result.fold(
      (failure) {
        print('❌ Login Failed: ${failure.message}');
        print('❌ Failure Type: ${failure.runtimeType}');
        emit(AuthUnauthenticated(message: failure.message));
      },
      (user) {
        _pendingUser = user;
        _pendingEmail = user.email;
        // Always emit authenticated - fingerprint setup will be handled in UI
        print('✅ User logged in: ${user.name ?? user.email}');
        print('✅ User Role: ${user.role.name}');
        emit(AuthAuthenticated(user: user));
      },
    );
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.checkAuthStatus();
    result.fold((failure) => emit(const AuthUnauthenticated()), (user) => emit(AuthAuthenticated(user: user)));
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    _pendingUser = null;
    _pendingEmail = '';
    emit(const AuthUnauthenticated());
  }

  Future<void> _onSendOTPRequested(SendOTPRequested event, Emitter<AuthState> emit) async {
    emit(Auth2FALoading());

    if (_pendingEmail == null) {
      emit(const Auth2FAError(message: 'Email not found. Please login again.'));
      return;
    }

    final result = await authRepository.sendTwoFactorCode(_pendingEmail!, event.method);

    result.fold(
      (failure) => emit(Auth2FAError(message: failure.message)),
      (success) => emit(Auth2FAOTPSent(method: event.method, message: 'Code sent successfully')),
    );
  }

  Future<void> _onOTPVerificationRequested(OTPVerificationRequested event, Emitter<AuthState> emit) async {
    emit(Auth2FALoading());

    if (_pendingEmail == null) {
      emit(const Auth2FAError(message: 'Session invalid. Please login again.'));
      return;
    }

    final result = await authRepository.verifyTwoFactorCode(
      _pendingEmail!,
      event.method,
      event.otp,
      event.rememberMe,
      event.preAuthRefreshToken,
    );

    result.fold((failure) => emit(Auth2FAError(message: failure.message)), (verified) {
      if (verified && _pendingUser != null) {
        emit(AuthAuthenticated(user: _pendingUser!));
        _pendingUser = null;
        _pendingEmail = null;
      } else {
        emit(const Auth2FAError(message: 'Verification failed. Please try again.'));
      }
    });
  }
}
