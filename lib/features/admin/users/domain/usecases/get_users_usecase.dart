// lib/features/admin/users/domain/usecases/get_users_usecase.dart

import 'package:dartz/dartz.dart';
import 'package:surabhi/core/domain/entities/user_entity.dart';
import 'package:surabhi/features/admin/users/domain/repositories/users_repository.dart';
import 'package:surabhi/core/errors/failures.dart';

class GetUsersUseCase {
  final UsersRepository repository;

  GetUsersUseCase(this.repository);

  /// Fetch users with infinite scroll support
  /// Returns a list of users for the given page and size
  Future<Either<Failure, List<UserEntity>>> call({int page = 1, int size = 20}) {
    // Validate input parameters
    if (page < 1) page = 1;
    if (size < 1) size = 20;
    if (size > 100) size = 100; // Prevent excessive page sizes

    return repository.getUsers(page: page, size: size);
  }
}
