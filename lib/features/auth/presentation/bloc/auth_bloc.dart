// lib/features/auth/presentation/bloc/auth_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/features/auth/data/models/user_model.dart';
import 'package:surabhi/features/auth/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<LoginButtonPressed>(_onLoginButtonPressed);
    on<RegisterButtonPressed>(_onRegisterButtonPressed);
    on<LogoutButtonPressed>(_onLogoutButtonPressed);
  }

  Future<void> _onAppStarted(AppStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCurrentUser(); // Checks for token and validates it
      if (user != null) {
        emit(AuthAuthenticated(user: user, role: user.role));
      } else {
        emit(AuthUnauthenticated());
      }
    } on AuthException catch (e) {
      // If any auth error during startup, clear and go to unauthenticated
      print('Auth error on AppStarted: ${e.message}');
      await authRepository.logout(); // Ensure data is cleared
      emit(AuthUnauthenticated());
    } catch (e) {
      // For any other unexpected error, assume unauthenticated
      print('Unexpected error on AppStarted: $e');
      emit(AuthError(message: 'Failed to check authentication status: $e'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginButtonPressed(LoginButtonPressed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.login(event.email, event.password);
      // After successful login, fetch the full user profile to get the latest data
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user, role: user.role));
      } else {
        // This case should ideally not happen if login was truly successful
        emit(AuthError(message: 'Login successful but failed to retrieve user profile.'));
        emit(AuthUnauthenticated());
      }
    } on AuthException catch (e) {
      emit(AuthError(message: 'Login failed: ${e.message}'));
      emit(AuthUnauthenticated());
    } on ServerException catch (e) {
      emit(AuthError(message: 'Server error during login: ${e.message}'));
      emit(AuthUnauthenticated());
    } on NetworkException catch (e) {
      emit(AuthError(message: 'Network error during login: ${e.message}'));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred: $e'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRegisterButtonPressed(RegisterButtonPressed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await authRepository.register(event.email, event.password, event.role);
      emit(AuthRegistrationSuccess());
      // Optionally, automatically log in the user after successful registration
      await authRepository.login(event.email, event.password);
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(AuthAuthenticated(user: user, role: user.role));
      } else {
        emit(AuthError(message: 'Registration successful but failed to auto-login. Please login manually.'));
        emit(AuthUnauthenticated());
      }
    } on ServerException catch (e) {
      emit(AuthError(message: 'Registration failed: ${e.message}'));
      emit(AuthUnauthenticated());
    } on NetworkException catch (e) {
      emit(AuthError(message: 'Network error during registration: ${e.message}'));
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred: $e'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogoutButtonPressed(LogoutButtonPressed event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await authRepository.logout();
    emit(AuthUnauthenticated());
  }
}