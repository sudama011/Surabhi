// lib/features/auth/domain/usecases/refresh_token_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:surabhi/features/auth/domain/entities/user_entity.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/features/auth/domain/repositories/auth_repository.dart';

/// Use case for refreshing authentication token
class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  /// Call the refresh token endpoint
  /// Returns a UserEntity with updated access token
  Future<Either<Failure, UserEntity>> call() {
    return repository.refreshToken();
  }
}
