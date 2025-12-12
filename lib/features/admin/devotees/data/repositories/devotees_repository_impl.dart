// lib/features/admin/devotees/data/repositories/devotees_repository_impl.dart

import 'package:dartz/dartz.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/features/admin/devotees/data/datasources/devotees_remote_datasource.dart';
import 'package:surabhi/features/admin/devotees/domain/entities/devotee_entity.dart';
import 'package:surabhi/features/admin/devotees/domain/repositories/devotees_repository.dart';

class DevoteesRepositoryImpl implements DevoteesRepository {
  final DevoteesRemoteDataSource remoteDataSource;

  DevoteesRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DevoteeEntity>>> getDevotees() async {
    try {
      final devotees = await remoteDataSource.getDevotees();
      return Right(devotees);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(UnhandledFailure(message: 'Failed to fetch devotees'));
    }
  }
}
