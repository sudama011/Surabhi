// lib/features/admin/users/domain/usecases/reset_user_password_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/features/admin/users/domain/repositories/users_repository.dart';

class ResetUserPasswordUseCase {
  final UsersRepository repository;

  ResetUserPasswordUseCase({required this.repository});

  Future<Either<Failure, bool>> call(ResetUserPasswordParams params) {
    return repository.resetUserPassword(params.email, params.newPassword);
  }
}

class ResetUserPasswordParams extends Equatable {
  final String email;
  final String newPassword;

  const ResetUserPasswordParams({required this.email, required this.newPassword});

  @override
  List<Object?> get props => [email, newPassword];
}
