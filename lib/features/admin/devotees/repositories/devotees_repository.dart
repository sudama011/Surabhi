// lib/features/admin/devotees/repositories/devotees_repository.dart

import 'package:dartz/dartz.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/features/admin/devotees/models/devotee_model.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/features/admin/devotees/datasources/devotees_remote_datasource.dart';

abstract class DevoteesRepository {
  Future<Either<Failure, List<DevoteeModel>>> getDevotees();
}

class DevoteesRepositoryImpl implements DevoteesRepository {
  final DevoteesRemoteDataSource _remoteDataSource;

  DevoteesRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, List<DevoteeModel>>> getDevotees() async {
    try {
      final devotees = await _remoteDataSource.getDevotees();
      return Right(devotees);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(UnhandledFailure(message: 'Failed to fetch devotees'));
    }
  }
}
