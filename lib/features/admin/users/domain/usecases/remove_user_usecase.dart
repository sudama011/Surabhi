// lib/features/admin/users/domain/usecases/remove_user_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/features/admin/users/domain/repositories/users_repository.dart';

class RemoveUserUseCase {
  final UsersRepository repository;

  RemoveUserUseCase({required this.repository});

  Future<Either<Failure, bool>> call(RemoveUserParams params) {
    return repository.removeUser(params.email);
  }
}

class RemoveUserParams extends Equatable {
  final String email;

  const RemoveUserParams({required this.email});

  @override
  List<Object?> get props => [email];
}
