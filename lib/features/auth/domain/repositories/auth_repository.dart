// lib/features/auth/domain/repositories/auth_repository.dart
import 'package:dartz/dartz.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';
import 'package:surabhi/features/auth/domain/usecases/login_usecase.dart';

abstract class AuthRepository {
  /// Login with email and password
  /// If 2FA is required, provide twoFactorCode in the second attempt
  Future<Either<Failure, UserEntity>> login(LoginParams params, {String? twoFactorCode});

  Future<Either<Failure, bool>> logout();

  Future<Either<Failure, UserEntity>> checkAuthStatus();

  /// Send 2FA code via email or phone
  Future<Either<Failure, bool>> sendTwoFactorCode(String email, String provider);

  /// Verify 2FA code
  Future<Either<Failure, bool>> verifyTwoFactorCode(String email, String provider, String code, bool rememberMe);

  /// Refresh access token using refresh token
  Future<Either<Failure, UserEntity>> refreshToken();
}
