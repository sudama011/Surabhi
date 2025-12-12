// lib/features/admin/devotees/domain/usecases/get_devotees_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/usecases/usecase.dart';
import 'package:surabhi/features/admin/devotees/domain/entities/devotee_entity.dart';
import 'package:surabhi/features/admin/devotees/domain/repositories/devotees_repository.dart';

class GetDevoteesUseCase implements UseCase<List<DevoteeEntity>, NoParams> {
  final DevoteesRepository repository;

  GetDevoteesUseCase(this.repository);

  @override
  Future<Either<Failure, List<DevoteeEntity>>> call(NoParams params) async {
    return await repository.getDevotees();
  }
}
