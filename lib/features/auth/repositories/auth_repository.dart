// lib/features/auth/domain/repositories/auth_repository.dart

import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/models/user_model.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/shared_preferences/preferences_service.dart';
import 'package:surabhi/features/auth/datasources/auth_remote_datasource.dart';

abstract class AuthRepository {

  Future<Either<Failure, UserModel>> login(String email, String password, bool rememberMe);

  Future<Either<Failure, bool>> logout();

  Future<Either<Failure, UserModel>> checkAuthStatus();

  Future<Either<Failure, bool>> sendTwoFactorCode(String email, String provider);

  Future<Either<Failure, bool>> verifyTwoFactorCode(String email, String provider, String code, bool rememberMe, String preAuthRefreshToken);

  Future<Either<Failure, UserModel>> refreshToken();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final PreferencesService preferencesService;

  AuthRepositoryImpl({required this.remoteDataSource, required this.preferencesService});

  @override
  Future<Either<Failure, UserModel>> login(String email, String password, bool rememberMe) async {
    try {
      final authResponse = await remoteDataSource.login(email, password, rememberMe);

      await preferencesService.saveAccessToken(authResponse.token);
      await preferencesService.saveRefreshToken(authResponse.refreshToken);

      UserModel user = authResponse.profile;

      final userJson = json.encode(user.toJson());
      await preferencesService.saveUserJson(userJson);
  
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(UnhandledFailure(message: 'An error occurred.'));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      // don't await this call, for smooth logout experience
      remoteDataSource.logout();
    } catch (e) {
      // Server-side logout failed, but we should proceed with local logout
    }
    await preferencesService.clearAuthData();
    return const Right(true);
  }

  @override
  Future<Either<Failure, UserModel>> checkAuthStatus() async {
    final userJson = preferencesService.getUserJson();
    if (userJson == null) {
      return const Left(AuthFailure(message: 'No user data found.'));
    }

    try {
      final Map<String, dynamic> userMap = json.decode(userJson);
      final userModel = UserModel.fromJson(userMap);
      return Right(userModel);
    } catch (e) {
      return const Left(CacheFailure(message: 'Failed to parse user data.'));
    }
  }

  @override
  Future<Either<Failure, bool>> sendTwoFactorCode(String email, String provider) async {
    try {
      await remoteDataSource.sendTwoFactor(email, provider);
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(UnhandledFailure(message: 'Failed to send 2FA code.'));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyTwoFactorCode(String email, String provider, String code, bool rememberMe, String preAuthRefreshToken) async {
    try {
      await remoteDataSource.verifyTwoFactor(email, provider, code, rememberMe: rememberMe, preAuthRefreshToken: preAuthRefreshToken);
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(UnhandledFailure(message: 'Failed to verify 2FA code.'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> refreshToken() async {
    try {
      final authResponse = await remoteDataSource.refreshToken();

      // Save new tokens
      await preferencesService.saveAccessToken(authResponse.token);
      await preferencesService.saveRefreshToken(authResponse.refreshToken);

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
}
