// lib/features/admin/users/data/datasources/users_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/core/data/models/user_model.dart';
import 'package:surabhi/core/data/models/paginated_response.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/network/api_client.dart';

abstract class UsersRemoteDataSource {
  Future<PaginatedResponse<UserModel>> getUsers({int page = 1, int size = 20});
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final ApiClient apiClient;

  UsersRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<PaginatedResponse<UserModel>> getUsers({int page = 1, int size = 20}) async {
    try {
      final response = await apiClient.dio.get(
        ApiConstants.userListPath,
        queryParameters: {'page': page, 'size': size},
      );

      final items = (response.data['items'] as List<dynamic>? ?? [])
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final meta = PaginationMeta.fromJson(response.data['meta'] as Map<String, dynamic>? ?? {});

      return PaginatedResponse(items: items, meta: meta);
    } on DioException catch (e) {
      throw ServerException(message: e.message ?? 'Failed to fetch users');
    }
  }
}
