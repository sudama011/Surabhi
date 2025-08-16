// lib/features/users/data/datasources/users_remote_datasource.dart
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/features/auth/data/models/user_model.dart';

class PaginatedUsers {
  final List<UserModel> items;
  final int page;
  final int size;
  final int total;
  final int pages;
  final bool hasNext;
  final bool hasPrev;

  PaginatedUsers({
    required this.items,
    required this.page,
    required this.size,
    required this.total,
    required this.pages,
    required this.hasNext,
    required this.hasPrev,
  });
}

abstract class UsersRemoteDataSource {
  Future<PaginatedUsers> getUsers({int page = 1, int size = 20});
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final ApiClient apiClient;
  UsersRemoteDataSourceImpl(this.apiClient);

  @override
  Future<PaginatedUsers> getUsers({int page = 1, int size = 20}) async {
    final res = await apiClient.dio.get('/users', queryParameters: {'page': page, 'size': size});
    final items = (res.data['items'] as List<dynamic>? ?? [])
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = res.data['meta'] as Map<String, dynamic>? ?? {};
    return PaginatedUsers(
      items: items,
      page: meta['page'] ?? page,
      size: meta['size'] ?? size,
      total: meta['total'] ?? 0,
      pages: meta['pages'] ?? 0,
      hasNext: meta['has_next'] ?? false,
      hasPrev: meta['has_prev'] ?? false,
    );
  }
}

