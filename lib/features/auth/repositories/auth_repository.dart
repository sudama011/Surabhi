// lib/features/auth/repositories/auth_repository.dart

import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/models/user_model.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/services/biometric_service.dart';
import 'package:surabhi/core/services/preferences_service.dart';
import 'package:surabhi/features/auth/datasources/auth_remote_datasource.dart';
import 'package:surabhi/features/auth/models/auth_response_model.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserModel>> login(String email, String password, bool rememberMe);

  Future<Either<Failure, bool>> logout();

  Future<Either<Failure, UserModel>> checkAuthStatus();

  Future<Either<Failure, bool>> sendTwoFactorCode(String email, String provider, String preAuthRefreshToken);

  Future<Either<Failure, UserModel>> verifyTwoFactorCode(
    String email,
    String provider,
    String code,
    bool rememberMe,
    String preAuthRefreshToken,
  );

  Future<Either<Failure, UserModel>> refreshToken({bool isForBiometricLogin = false});
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final PreferencesService preferencesService;
  final BiometricService biometricService;

  AuthRepositoryImpl({
    required this.authRemoteDataSource,
    required this.preferencesService,
    required this.biometricService,
  });

  @override
  Future<Either<Failure, UserModel>> login(String email, String password, bool rememberMe) async {
    try {
      final response = await authRemoteDataSource.login(email, password, rememberMe);
      return _handleAuthResponse(response);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnhandledFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> checkAuthStatus() async {
    final userJson = preferencesService.getUserJson();
    if (userJson == null) if (userJson == null) return const Left(AuthFailure(message: 'No session found'));
    try {
      return Right(UserModel.fromJson(json.decode(userJson)));
    } catch (e) {
      return const Left(CacheFailure(message: 'Session corrupted'));
    }
  }

  @override
  Future<Either<Failure, bool>> sendTwoFactorCode(String email, String provider, String preAuthRefreshToken) async {
    try {
      await authRemoteDataSource.sendTwoFactor(email, provider, preAuthRefreshToken);
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(UnhandledFailure(message: 'Failed to send 2FA code.'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> verifyTwoFactorCode(
    String email,
    String provider,
    String code,
    bool rememberMe,
    String preAuthRefreshToken,
  ) async {
    try {
      final response = await authRemoteDataSource.verifyTwoFactor(
        email,
        provider,
        code,
        rememberMe: rememberMe,
        preAuthRefreshToken: preAuthRefreshToken,
      );
      return _handleAuthResponse(response);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnhandledFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> refreshToken({bool isForBiometricLogin = false}) async {
    try {
      String storedRefreshToken = '';

      if (isForBiometricLogin) {
        // Retrieve refresh token for biometric login
        final refreshToken = await biometricService.authenticateAndGetToken();
        if (refreshToken == null) {
          return const Left(AuthFailure(message: 'Biometric authentication cancelled or not available'));
        }
        storedRefreshToken = refreshToken;
      } else {
        // Retrieve refresh token for session extension
        final refreshToken = await preferencesService.getRefreshToken();
        if (refreshToken == null) {
          return const Left(AuthFailure(message: 'No refresh token found.'));
        }
        storedRefreshToken = refreshToken;
      }

      final authResponse = await authRemoteDataSource.refreshToken(storedRefreshToken);

      // Save new tokens
      await _saveAuthData(authResponse);

      // Get stored user data to maintain role and other info
      final userJson = preferencesService.getUserJson();
      if (userJson != null && userJson.isNotEmpty && userJson != '{}') {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        final user = UserModel.fromJson(userMap);
        return Right(user);
      }

      return const Left(CacheFailure(message: 'Failed to parse user data.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to refresh token: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      // don't await this call, for smooth logout experience
      authRemoteDataSource.logout();
    } catch (e) {
      // Server-side logout failed, but we should proceed with local logout
    }
    await preferencesService.clearAuthData();
    return const Right(true);
  }

  Future<Either<Failure, UserModel>> _handleAuthResponse(AuthResponseModel response) async {
    // 1. Check for 2FA Requirement
    if (response.requiresTwoFactor) {
      return Left(
        TwoFactorRequiredFailure(providers: response.providers ?? [], preAuthRefreshToken: response.refreshToken),
      );
    }

    // 2. Check for Success (Must have Token & Profile)
    if (response.token != null && response.profile != null) {
      await _saveAuthData(response);
      return Right(response.profile!);
    }

    return const Left(AuthFailure(message: 'Authentication failed. Invalid server response.'));
  }

  Future<void> _saveAuthData(AuthResponseModel response) async {
    await preferencesService.saveAccessToken(response.token!);
    await preferencesService.saveTokenExpiry(response.expiresAt!);
    await preferencesService.saveRefreshToken(response.refreshToken);

    if (response.profile != null) {
      final userJson = json.encode(response.profile!.toJson());
      await preferencesService.saveUserJson(userJson);
    }
  }
}
