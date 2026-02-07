// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/models/user_model.dart';
import 'package:surabhi/core/services/biometric_service.dart';
import 'package:surabhi/features/auth/repositories/auth_repository.dart';
import 'package:surabhi/features/auth/models/twofa_provider_model.dart';
import 'package:surabhi/core/errors/failures.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final BiometricService biometricService;

  // Temporary state for 2FA flow
  String? _pendingEmail;
  String? _preAuthRefreshToken;
  TwoFAProvider? _selectedProvider;

  AuthBloc(this.authRepository, this.biometricService) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SendOTPRequested>(_onSendOTPRequested);
    on<OTPVerificationRequested>(_onOTPVerificationRequested);
    on<AppStarted>(_onAppStarted);
    on<BiometricLoginRequested>(_onBiometricLoginRequested);
    on<SessionExtendRequested>(_onSessionExtendRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<UserUpdated>(_onUserUpdated);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.login(event.email, event.password);
    result.fold(
      (failure) {
        if (failure is TwoFactorRequiredFailure) {
          _pendingEmail = event.email;
          _preAuthRefreshToken = failure.preAuthRefreshToken;

          // Auto-select if only 1 provider exists (UX Improvement)
          if (failure.providers.length == 1) {
            emit(Auth2FALoading());
            add(SendOTPRequested(provider: failure.providers.first));
          } else {
            // Let user choose
            emit(Auth2FARequired(providers: failure.providers));
          }
        } else {
          emit(AuthUnauthenticated(message: failure.message));
        }
      },
      (user) {
        emit(AuthAuthenticated(user: user));
      },
    );
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final isBioEnabled = await biometricService.isBiometricEnabled;
    if (isBioEnabled) {
      // Case A: Biometric Enabled -> Force Login Page
      // The Login Page will detect isBioEnabled on init and trigger the prompt.
      // We emit Unauthenticated so the Router redirects to '/'
      emit(const AuthUnauthenticated());
    } else {
      // Case B: Biometric Disabled -> Try Auto-Login (Restore Session)
      // We use refreshToken to check if we have a valid session token (30 days)
      final result = await authRepository.refreshToken();
      result.fold(
        (failure) => emit(AuthUnauthenticated(message: failure.message)), // Failed? Go to Login
        (user) => emit(AuthAuthenticated(user: user)), // Success? Go to Dashboard
      );
    }
  }

  Future<void> _onBiometricLoginRequested(BiometricLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthBiometricLoading());

    final result = await authRepository.loginWithBiometrics();

    result.fold((failure) {
      // Don't show error state usually, just let them use the form.
      // Or show a snackbar via a side-effect (Listener)
      emit(AuthBiometricFailure(message: failure.message));
    }, (user) => emit(AuthAuthenticated(user: user)));
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    _pendingEmail = null;
    _preAuthRefreshToken = null;
    emit(const AuthUnauthenticated());
  }

  Future<void> _onSendOTPRequested(SendOTPRequested event, Emitter<AuthState> emit) async {
    emit(Auth2FALoading());

    if (_pendingEmail == null) {
      emit(const Auth2FAError(message: 'Session expired. Please login again.'));
      return;
    }

    _selectedProvider = event.provider;
    final result = await authRepository.sendTwoFactorCode(_pendingEmail!, event.provider.type, _preAuthRefreshToken!);

    result.fold(
      (failure) => emit(Auth2FAError(message: failure.message)),
      (success) => emit(
        Auth2FAOTPSent(provider: event.provider, message: 'Code sent successfully to ${event.provider.maskedValue}'),
      ),
    );
  }

  Future<void> _onOTPVerificationRequested(OTPVerificationRequested event, Emitter<AuthState> emit) async {
    emit(Auth2FALoading());

    if (_pendingEmail == null || _preAuthRefreshToken == null || _selectedProvider == null) {
      emit(const Auth2FAError(message: 'Session invalid. Please login again.'));
      return;
    }

    final result = await authRepository.verifyTwoFactorCode(
      _pendingEmail!,
      _selectedProvider!.type,
      event.otp,
      _preAuthRefreshToken!,
    );

    result.fold((failure) => emit(Auth2FAError(message: failure.message)), (user) {
      // Clear temporary state on success
      _pendingEmail = null;
      _preAuthRefreshToken = null;
      _selectedProvider = null;
      emit(AuthAuthenticated(user: user));
    });
  }

  Future<void> _onSessionExtendRequested(SessionExtendRequested event, Emitter<AuthState> emit) async {
    final result = await authRepository.refreshToken();
    result.fold(
      (failure) {
        // If extension fails, we must logout
        add(LogoutRequested());
        emit(const AuthUnauthenticated(message: 'Session expired. Please login again.'));
      },
      (user) {
        // Success! Token is refreshed (Repo saves new token/expiry automatically)
        emit(AuthAuthenticated(user: user));
      },
    );
  }

  Future<void> _onUserUpdated(UserUpdated event, Emitter<AuthState> emit) async {
    emit(AuthAuthenticated(user: event.user));
  }
}
