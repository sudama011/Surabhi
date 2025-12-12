// lib/features/admin/roles/domain/usecases/get_roles_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/core/usecases/usecase.dart';
import 'package:surabhi/features/admin/roles/domain/entities/role_entity.dart';
import 'package:surabhi/features/admin/roles/domain/repositories/roles_repository.dart';

class GetRolesUseCase implements UseCase<List<RoleEntity>, NoParams> {
  final RolesRepository repository;

  GetRolesUseCase(this.repository);

  @override
  Future<Either<Failure, List<RoleEntity>>> call(NoParams params) async {
    return await repository.getRoles();
  }
}
