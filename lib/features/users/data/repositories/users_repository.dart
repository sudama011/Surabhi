// lib/features/users/data/repositories/users_repository.dart
import 'package:surabhi/features/users/data/datasources/users_remote_datasource.dart';

class UsersRepository {
  final UsersRemoteDataSource remote;
  UsersRepository(this.remote);

  Future<PaginatedUsers> getUsers({int page = 1, int size = 20}) => remote.getUsers(page: page, size: size);
}

