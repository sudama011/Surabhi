// lib/features/admin/users/domain/usecases/change_user_role_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/features/admin/users/domain/repositories/users_repository.dart';

class ChangeUserRoleUseCase {
  final UsersRepository repository;

  ChangeUserRoleUseCase({required this.repository});

  Future<Either<Failure, bool>> call(ChangeUserRoleParams params) {
    return repository.changeUserRole(params.email, params.newRole);
  }
}

class ChangeUserRoleParams extends Equatable {
  final String email;
  final String newRole;

  const ChangeUserRoleParams({required this.email, required this.newRole});

  @override
  List<Object?> get props => [email, newRole];
}
