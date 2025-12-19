// lib/features/auth/repositories/auth_repository.dart

import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/models/user_model.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/services/biometric_service.dart';
import 'package:surabhi/core/services/storage_service.dart';
import 'package:surabhi/features/auth/datasources/auth_remote_datasource.dart';
import 'package:surabhi/features/auth/models/auth_response_model.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/features/profile/datasources/profile_remote_datasource.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserModel>> login(String email, String password);

  Future<Either<Failure, bool>> logout();

  Future<Either<Failure, bool>> sendTwoFactorCode(String email, String provider, String preAuthRefreshToken);

  Future<Either<Failure, UserModel>> verifyTwoFactorCode(
    String email,
    String provider,
    String code,
    String preAuthRefreshToken,
  );

  Future<Either<Failure, UserModel>> loginWithBiometrics();

  Future<Either<Failure, UserModel>> refreshToken();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;
  final StorageService storageService;
  final BiometricService biometricService;
  final ProfileRemoteDataSource profileRemoteDataSource;

  AuthRepositoryImpl(
    this.authRemoteDataSource,
    this.storageService,
    this.biometricService,
    this.profileRemoteDataSource,
  );

  @override
  Future<Either<Failure, UserModel>> login(String email, String password) async {
    try {
      final response = await authRemoteDataSource.login(email, password);
      return await _handleAuthResponse(response);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnhandledFailure(message: e.toString()));
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
    String preAuthRefreshToken,
  ) async {
    try {
      final response = await authRemoteDataSource.verifyTwoFactor(email, provider, code, preAuthRefreshToken);
      return await _handleAuthResponse(response);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnhandledFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> loginWithBiometrics() async {
    try {
      final didAuthenticate = await biometricService.authenticate();
      if (!didAuthenticate) {
        return const Left(AuthFailure(message: 'Biometric authentication failed.'));
      }
      return await refreshToken();
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnhandledFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserModel>> refreshToken() async {
    try {
      final refreshToken = await storageService.getRefreshToken();

      if (refreshToken == null) {
        return const Left(AuthFailure(message: 'Session expired. Please login again.'));
      }

      final authResponse = await authRemoteDataSource.refreshToken(refreshToken);
      await _saveAuthData(authResponse);

      final userJson = await storageService.getUserJson();
      if (userJson != null) {
        return Right(UserModel.fromJson(json.decode(userJson)));
      }

      final userProfile = await profileRemoteDataSource.getProfile();
      await storageService.saveUserJson(json.encode(userProfile.toJson()));
      return Right(userProfile);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to refresh token: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      authRemoteDataSource.logout(); // Fire and forget
    } catch (_) {}
    await storageService.clearAuthData();
    return const Right(true);
  }

  // --- HELPER METHODS ---

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
    if (response.token != null) {
      await storageService.saveAccessToken(response.token!);
    }
    if (response.expiresAt != null) {
      await storageService.saveTokenExpiry(response.expiresAt!);
    }

    await storageService.saveRefreshToken(response.refreshToken);
    await storageService.saveRefreshTokenExpiry(response.refreshTokenExpiresAt);

    if (response.profile != null) {
      await storageService.saveUserJson(json.encode(response.profile!.toJson()));
    }
  }
}
