// lib/features/auth/data/repositories/auth_repository.dart
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/shared_preferences/preferences_service.dart';
import 'package:surabhi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:surabhi/features/auth/data/models/user_model.dart';

abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<void> register(String email, String password, String role);
  Future<void> logout();
  Future<UserModel?> getCurrentUser(); // Fetches and returns current user info if authenticated
  Future<String?> getUserRole(); // Gets user role from stored preferences
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final PreferencesService preferencesService;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.preferencesService,
  });

  @override
  Future<void> login(String email, String password) async {
    try {
      final authResponse = await remoteDataSource.login(email, password);
      await preferencesService.saveAccessToken(authResponse.accessToken);
      await preferencesService.saveRefreshToken(authResponse.refreshToken);
      await preferencesService.saveUserRole(authResponse.userRole);
      // Optional: Fetch full user profile immediately after login to ensure complete data
      // final user = await remoteDataSource.getProfile();
      // await preferencesService.saveUser(user); // If you had a saveUser method
    } catch (e) {
      rethrow; // Re-throw exceptions for BLoC to handle
    }
  }

  @override
  Future<void> register(String email, String password, String role) async {
    try {
      await remoteDataSource.register(email, password, role);
    } catch (e) {
      rethrow; // Re-throw exceptions
    }
  }

  @override
  Future<void> logout() async {
    await preferencesService.clearAuthData();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final accessToken = await preferencesService.getAccessToken();
    if (accessToken == null) {
      return null; // No token, no authenticated user
    }
    // Try to fetch profile to validate token and get up-to-date user data
    try {
      final user = await remoteDataSource.getProfile();
      // Also ensure the role in preferences is updated/correct
      await preferencesService.saveUserRole(user.role);
      return user;
    } on AuthException {
      // Token expired or invalid, clear data and indicate no user
      await preferencesService.clearAuthData();
      return null;
    } catch (e) {
      // Other errors (network, server) - treat as unauthenticated for now
      print('Error getting current user profile: $e');
      return null;
    }
  }

  @override
  Future<String?> getUserRole() async {
    return preferencesService.getUserRole();
  }
}