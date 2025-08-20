// lib/features/users/data/repositories/users_repository.dart
import 'package:surabhi/features/users/data/datasources/users_remote_datasource.dart';
import 'package:surabhi/core/data/models/paginated_response.dart';
import 'package:surabhi/core/data/models/user_model.dart';

class UsersRepository {
  final UsersRemoteDataSource remote;
  UsersRepository(this.remote);

  Future<PaginatedResponse<UserModel>> getUsers({int page = 1, int size = 20}) =>
      remote.getUsers(page: page, size: size);
}
