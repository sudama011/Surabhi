// lib/features/home/repositories/home_repository.dart

import 'package:dartz/dartz.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/features/home/models/home_summary_model.dart';
import 'package:surabhi/features/home/datasources/home_remote_datasource.dart';

abstract class HomeRepository {
  Future<Either<Failure, HomeSummaryModel>> getHomeSummary();
}

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, HomeSummaryModel>> getHomeSummary() async {
    try {
      final summary = await _remoteDataSource.getHomeSummary();
      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } catch (e) {
      return const Left(UnhandledFailure(message: 'Failed to fetch home summary'));
    }
  }
}
