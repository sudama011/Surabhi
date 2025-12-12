// lib/features/admin/roles/data/datasources/roles_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/utils/error_utils.dart';
import 'package:surabhi/features/admin/roles/data/models/role_model.dart';

abstract class RolesRemoteDataSource {
  Future<List<RoleModel>> getRoles();
}

class RolesRemoteDataSourceImpl implements RolesRemoteDataSource {
  final ApiClient apiClient;

  RolesRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<RoleModel>> getRoles() async {
    try {
      final response = await apiClient.dio.get(ApiConstants.userRolesPath);

      // Handle both array and map response formats
      List<dynamic> rolesList;
      if (response.data is List) {
        rolesList = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['roles'] != null) {
        rolesList = response.data['roles'] as List<dynamic>;
      } else {
        rolesList = [];
      }

      return rolesList.map((role) => RoleModel.fromJson(role as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      final errorMessage = ErrorUtils.getComprehensiveErrorMessage(e, 'Failed to fetch roles');
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }
}
