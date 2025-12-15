// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/models/user_model.dart';
import 'package:surabhi/features/auth/repositories/auth_repository.dart';
import 'package:surabhi/features/auth/models/twofa_provider_model.dart';
import 'package:surabhi/core/errors/failures.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  String? _pendingEmail;
  String? _preAuthRefreshToken;
  bool _rememberMe = false;
  TwoFAProvider? _selectedProvider;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<SendOTPRequested>(_onSendOTPRequested);
    on<OTPVerificationRequested>(_onOTPVerificationRequested);
    on<AppStarted>(_onAppStarted);
    on<BiometricLoginRequested>(_onBiometricLoginRequested);
    on<SessionExtendRequested>(_onSessionExtendRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await authRepository.login(event.email, event.password, event.rememberMe);
    result.fold(
      (failure) {
        if (failure is TwoFactorRequiredFailure) {
          _pendingEmail = event.email;
          _preAuthRefreshToken = failure.preAuthRefreshToken;
          _rememberMe = event.rememberMe;

          // Auto-select if only 1 provider exists
          if (failure.providers.length == 1) {
            // Emit a transient loading state for better UX
            emit(Auth2FALoading());

            // Trigger the send logic immediately
            add(SendOTPRequested(provider: failure.providers.first));
          } else {
            // Let user choose from list
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
    final result = await authRepository.checkAuthStatus();
    result.fold((_) => emit(const AuthUnauthenticated()), (user) => emit(AuthAuthenticated(user: user)));
  }

  Future<void> _onBiometricLoginRequested(BiometricLoginRequested event, Emitter<AuthState> emit) async {
    // We don't emit AuthLoading here to avoid flickering the whole screen
    // or use a specific AuthBiometricLoading if you want a spinner.

    final result = await authRepository.refreshToken(isForBiometricLogin: true);

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

    if (_pendingEmail == null || _preAuthRefreshToken == null) {
      emit(const Auth2FAError(message: 'Session invalid. Please login again.'));
      return;
    }

    final result = await authRepository.verifyTwoFactorCode(
      _pendingEmail!,
      _selectedProvider!.type,
      event.otp,
      _rememberMe,
      _preAuthRefreshToken!,
    );

    result.fold((failure) => emit(Auth2FAError(message: failure.message)), (user) {
      // Clear temporary state on success
      _pendingEmail = null;
      _preAuthRefreshToken = null;
      _selectedProvider = null;
      _rememberMe = false;
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
}
