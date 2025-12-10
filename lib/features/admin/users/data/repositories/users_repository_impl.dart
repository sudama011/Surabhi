// lib/features/admin/users/data/repositories/users_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:surabhi/features/admin/users/data/datasources/users_remote_datasource.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';
import 'package:surabhi/features/admin/users/domain/repositories/users_repository.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/errors/failures.dart';

class UsersRepositoryImpl implements UsersRepository {
  final UsersRemoteDataSource remoteDataSource;

  UsersRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<UserEntity>>> getUsers({int page = 1, int size = 20}) async {
    try {
      final users = await remoteDataSource.getUsers(page: page, size: size);
      final userEntities = users.map((user) => user as UserEntity).toList();
      return Right(userEntities);
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
  Future<Either<Failure, bool>> changeUserRole(String email, String newRole) async {
    try {
      await remoteDataSource.changeUserRole(email, newRole);
      return const Right(true);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    }
  }
}
