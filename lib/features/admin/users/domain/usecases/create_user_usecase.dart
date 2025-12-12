// lib/features/admin/users/domain/usecases/create_user_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:surabhi/core/errors/failures.dart';
import 'package:surabhi/features/admin/users/domain/repositories/users_repository.dart';

class CreateUserUseCase {
  final UsersRepository repository;

  CreateUserUseCase({required this.repository});

  Future<Either<Failure, bool>> call(CreateUserParams params) {
    return repository.createUser(
      email: params.email,
      password: params.password,
      phoneNumber: params.phoneNumber,
      role: params.role,
    );
  }
}

class CreateUserParams extends Equatable {
  final String email;
  final String password;
  final String phoneNumber;
  final String role;

  const CreateUserParams({
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.role,
  });

  @override
  List<Object?> get props => [email, password, phoneNumber, role];
}
