// lib/features/admin/roles/domain/repositories/roles_repository.dart

import 'package:dartz/dartz.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/features/admin/roles/domain/entities/role_entity.dart';

abstract class RolesRepository {
  Future<Either<Failure, List<RoleEntity>>> getRoles();
}
