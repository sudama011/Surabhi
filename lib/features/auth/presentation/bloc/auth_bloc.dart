// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/features/auth/domain/repositories/auth_repository.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';
import 'package:surabhi/features/auth/domain/usecases/login_usecase.dart';
import 'package:surabhi/features/auth/domain/usecases/request_2fa_usecase.dart';
import 'package:surabhi/features/auth/domain/usecases/verify_otp_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final AuthRepository authRepository;
  final Request2FAUseCase request2FAUseCase;
  final VerifyOTPUseCase verifyOTPUseCase;

  // Store user temporarily during 2FA flow
  UserEntity? _pendingUser;

  AuthBloc({
    required this.loginUseCase,
    required this.authRepository,
    required this.request2FAUseCase,
    required this.verifyOTPUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<AppStarted>(_onAppStarted);
    on<LogoutRequested>(_onLogoutRequested);
    on<TwoFAMethodSelected>(_onTwoFAMethodSelected);
    on<OTPVerificationRequested>(_onOTPVerificationRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(LoginParams(email: event.email, password: event.password));
    result.fold((failure) => emit(AuthUnauthenticated(message: failure.message)), (user) {
      _pendingUser = user;
      // Check if user has 2FA enabled
      if (user.is2faEnabled) {
        emit(Auth2FARequired(user: user));
      } else {
        emit(AuthAuthenticated(user: user));
      }
    });
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.checkAuthStatus();
    result.fold((failure) => emit(const AuthUnauthenticated()), (user) => emit(AuthAuthenticated(user: user)));
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    _pendingUser = null;
    emit(const AuthUnauthenticated());
  }

  Future<void> _onTwoFAMethodSelected(TwoFAMethodSelected event, Emitter<AuthState> emit) async {
    emit(Auth2FALoading());
    final result = await request2FAUseCase(Request2FAParams(method: event.method));
    result.fold(
      (failure) => emit(Auth2FAError(message: failure.message)),
      (message) => emit(Auth2FAOTPSent(method: event.method, message: message)),
    );
  }

  Future<void> _onOTPVerificationRequested(OTPVerificationRequested event, Emitter<AuthState> emit) async {
    emit(Auth2FALoading());
    final result = await verifyOTPUseCase(VerifyOTPParams(otp: event.otp, method: event.method));
    result.fold((failure) => emit(Auth2FAError(message: failure.message)), (verified) {
      if (verified && _pendingUser != null) {
        emit(AuthAuthenticated(user: _pendingUser!));
        _pendingUser = null;
      } else {
        emit(const Auth2FAError(message: 'Verification failed. Please try again.'));
      }
    });
  }
}
