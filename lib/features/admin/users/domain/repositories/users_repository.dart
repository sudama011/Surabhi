// lib/features/admin/users/domain/repositories/users_repository.dart

import 'package:dartz/dartz.dart';
import 'package:surabhi/features/admin/users/domain/entities/register_user_entity.dart';
import 'package:surabhi/core/errors/failures.dart';

abstract class UsersRepository {
  /// Fetch users with pagination support for infinite scroll
  /// Returns a list of users for the given page and size
  Future<Either<Failure, List<RegisterUserEntity>>> getUsers({int page = 1, int size = 20});

  /// Reset a user's password (admin only)
  Future<Either<Failure, bool>> resetUserPassword(String email, String newPassword);

  /// Remove a user (admin only)
  Future<Either<Failure, bool>> removeUser(String email);

  /// Change a user's role (admin only)
  Future<Either<Failure, bool>> changeUserRole(String email, String newRole);
}
