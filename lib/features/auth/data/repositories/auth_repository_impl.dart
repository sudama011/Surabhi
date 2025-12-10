// lib/features/auth/data/repositories/auth_repository.dart
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/shared_preferences/preferences_service.dart';
import 'package:surabhi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:surabhi/core/data/models/user_model.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';
import 'package:surabhi/features/auth/domain/usecases/login_usecase.dart';
import 'package:surabhi/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final PreferencesService preferencesService;

  AuthRepositoryImpl({required this.remoteDataSource, required this.preferencesService});

  @override
  Future<Either<Failure, UserEntity>> login(LoginParams params, {String? twoFactorCode}) async {
    try {
      final authResponse = await remoteDataSource.login(params, twoFactorCode: twoFactorCode);

      // Save tokens
      await preferencesService.saveAccessToken(authResponse.token);
      await preferencesService.saveRefreshToken(authResponse.refreshToken);

      // Get user profile data from the profile endpoint
      final profileResult = await remoteDataSource.getUserProfile(params.email);

      UserModel user;
      if (profileResult != null) {
        // Use the profile data and add the role from login response
        user = UserModel(
          id: profileResult.userId,
          userName: profileResult.email,
          role: authResponse.roles.isNotEmpty ? authResponse.roles.first : 'user',
          firstName: profileResult.firstName,
          lastName: profileResult.lastName,
          phoneNumber: profileResult.phoneNumber,
          image: profileResult.image,
          emailVerified: profileResult.emailVerified,
          phoneVerified: profileResult.phoneVerified,
        );
      } else {
        // Fallback: Create user from login response
        user = UserModel(
          id: params.email,
          userName: params.email,
          role: authResponse.roles.isNotEmpty ? authResponse.roles.first : 'user',
          image: null,
        );
      }

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
      // Assuming a server-side logout is not critical for local state
      await remoteDataSource.logout();
    } catch (e) {
      // Server-side logout failed, but we should proceed with local logout
    }
    await preferencesService.clearAuthData();
    return const Right(true);
  }

  @override
  Future<Either<Failure, UserEntity>> checkAuthStatus() async {
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
  Future<Either<Failure, bool>> verifyTwoFactorCode(String email, String provider, String code, bool rememberMe) async {
    try {
      await remoteDataSource.verifyTwoFactor(email, provider, code, rememberMe: rememberMe);
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(UnhandledFailure(message: 'Failed to verify 2FA code.'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> refreshToken() async {
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

      // Fallback: Create minimal user entity with role from response
      final user = UserModel(
        id: 'unknown',
        userName: 'unknown',
        role: authResponse.roles.isNotEmpty ? authResponse.roles.first : 'user',
      );
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to refresh token: $e'));
    }
  }
}
