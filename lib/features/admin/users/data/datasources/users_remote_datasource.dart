// lib/features/admin/users/data/datasources/users_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/features/admin/users/data/models/register_user_model.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/core/utils/error_utils.dart';

abstract class UsersRemoteDataSource {
  /// Fetch users with pagination support for infinite scroll
  Future<List<RegisterUserModel>> getUsers({int page = 1, int size = 20});

  Future<void> resetUserPassword(String email, String newPassword);

  Future<void> removeUser(String email);

  Future<void> changeUserRole(String email, String newRole);
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final ApiClient apiClient;

  UsersRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<RegisterUserModel>> getUsers({int page = 1, int size = 20}) async {
    try {
      final response = await apiClient.dio.get(ApiConstants.userListPath);

      // Handle both array and paginated response formats
      List<dynamic> itemsList;
      if (response.data is List) {
        itemsList = response.data as List<dynamic>;
      } else if (response.data is Map && response.data['users'] != null) {
        itemsList = response.data['users'] as List<dynamic>;
      } else {
        itemsList = [];
      }

      final items = itemsList.map((e) => RegisterUserModel.fromJson(e as Map<String, dynamic>)).toList();

      return items;
    } on DioException catch (e) {
      // Extract user-friendly message from API response
      final errorMessage = ErrorUtils.getComprehensiveErrorMessage(e, 'Failed to fetch users');
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<void> resetUserPassword(String email, String newPassword) async {
    try {
      final data = {'email': email, 'newPassword': newPassword};
      await apiClient.dio.post(
        ApiConstants.adminResetPasswordPath,
        data: data,
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      final errorMessage = ErrorUtils.getComprehensiveErrorMessage(e, 'Failed to reset password');
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<void> removeUser(String email) async {
    try {
      final data = {'email': email};
      await apiClient.dio.post(
        ApiConstants.adminRemoveUserPath,
        data: data,
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      final errorMessage = ErrorUtils.getComprehensiveErrorMessage(e, 'Failed to remove user');
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<void> changeUserRole(String email, String newRole) async {
    try {
      final data = {'email': email, 'userRole': newRole};
      await apiClient.dio.post(
        ApiConstants.adminChangeRolePath,
        data: data,
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      final errorMessage = ErrorUtils.getComprehensiveErrorMessage(e, 'Failed to change user role');
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }
}
