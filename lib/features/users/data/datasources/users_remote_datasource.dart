// lib/features/users/data/datasources/users_remote_datasource.dart
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/core/data/models/user_model.dart';
import 'package:surabhi/core/data/models/paginated_response.dart';

abstract class UsersRemoteDataSource {
  Future<PaginatedResponse<UserModel>> getUsers({int page = 1, int size = 20});
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final ApiClient apiClient;
  UsersRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PaginatedResponse<UserModel>> getUsers({int page = 1, int size = 20}) async {
    final res = await apiClient.dio.get('/users', queryParameters: {'page': page, 'size': size});
    final items = (res.data['items'] as List<dynamic>? ?? [])
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = PaginationMeta.fromJson(res.data['meta'] as Map<String, dynamic>? ?? {});
    return PaginatedResponse(items: items, meta: meta);
  }
}
