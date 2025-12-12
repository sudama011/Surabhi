// lib/features/admin/devotees/domain/repositories/devotees_repository.dart

import 'package:dartz/dartz.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/features/admin/devotees/domain/entities/devotee_entity.dart';

abstract class DevoteesRepository {
  Future<Either<Failure, List<DevoteeEntity>>> getDevotees();
}
