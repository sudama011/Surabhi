// lib/features/admin/roles/data/repositories/roles_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/features/admin/roles/data/datasources/roles_remote_datasource.dart';
import 'package:surabhi/features/admin/roles/domain/entities/role_entity.dart';
import 'package:surabhi/features/admin/roles/domain/repositories/roles_repository.dart';

class RolesRepositoryImpl implements RolesRepository {
  final RolesRemoteDataSource remoteDataSource;

  RolesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<RoleEntity>>> getRoles() async {
    try {
      final roles = await remoteDataSource.getRoles();
      return Right(roles);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(UnhandledFailure(message: 'Failed to fetch roles'));
    }
  }
}
