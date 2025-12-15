// lib/features/admin/users/repositories/users_repository.dart

import 'package:dartz/dartz.dart';
import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/features/admin/users/models/registered_user_model.dart';
import 'package:surabhi/features/admin/users/datasources/users_remote_datasource.dart';

abstract class UsersRepository {
  /// Fetch users with infinite scroll support
  Future<Either<Failure, List<RegisteredUserModel>>> getUsers({int page = 1, int size = 20});

  /// Create a new user (admin only)
  Future<Either<Failure, bool>> createUser({
    required String email,
    required String password,
    required String phoneNumber,
    required Role role,
  });

  /// Reset a user's password (admin only)
  Future<Either<Failure, bool>> resetUserPassword(String email, String newPassword);

  /// Remove a user (admin only)
  Future<Either<Failure, bool>> removeUser(String email);

  /// Change a user's role (admin only)
  Future<Either<Failure, bool>> changeUserRole(String email, Role newRole);
}

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;

  UsersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<RegisteredUserModel>>> getUsers({int page = 1, int size = 20}) async {
    try {
      final users = await remoteDataSource.getUsers(page: page, size: size);
      return Right(users);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> createUser({
    required String email,
    required String password,
    required String phoneNumber,
    required Role role,
  }) async {
    try {
      await remoteDataSource.createUser(email: email, password: password, phoneNumber: phoneNumber, role: role.name);
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> resetUserPassword(String email, String newPassword) async {
    try {
      await remoteDataSource.resetUserPassword(email, newPassword);
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> removeUser(String email) async {
    try {
      await remoteDataSource.removeUser(email);
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> changeUserRole(String email, Role newRole) async {
    try {
      await remoteDataSource.changeUserRole(email, newRole.name);
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}
