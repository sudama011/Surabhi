// lib/features/donors/repositories/donors_repository.dart

import 'package:dartz/dartz.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/features/donors/models/donor_model.dart';
import 'package:surabhi/features/donors/datasources/donors_remote_datasource.dart';

abstract class DonorsRepository {
  Future<Either<Failure, DonorSearchResponse>> searchDonors({
    required int pageNumber,
    required int pageSize,
    String? searchText,
    bool isPatron = false,
  });
}

class DonorsRepositoryImpl implements DonorsRepository {
  final DonorsRemoteDataSource _remoteDataSource;

  DonorsRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, DonorSearchResponse>> searchDonors({
    required int pageNumber,
    required int pageSize,
    String? searchText,
    bool isPatron = false,
  }) async {
    try {
      final response = await _remoteDataSource.searchDonors(
        pageNumber: pageNumber,
        pageSize: pageSize,
        searchText: searchText,
        isPatron: isPatron,
      );
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return const Left(UnhandledFailure(message: 'Failed to search donors'));
    }
  }
}
