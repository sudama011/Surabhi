// lib/features/admin/users/data/datasources/users_remote_datasource.dart

import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/features/admin/users/models/registered_user_model.dart';
import 'package:surabhi/core/network/api_client.dart';

abstract class UsersRemoteDataSource {
  Future<void> createUser({
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
  });

  Future<List<RegisteredUserModel>> getUsers({int page, int size});

  Future<void> resetUserPassword(String email, String newPassword);

  Future<void> removeUser(String email);

  Future<void> changeUserRole(String email, String newRole);
}

class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final ApiClient _apiClient;

  UsersRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<RegisteredUserModel>> getUsers({int page = 1, int size = 20}) async {
    final response = await _apiClient.get(ApiConstants.userListPath);

    // Handle both array and paginated response formats
    List<dynamic> itemsList;
    if (response is List) {
      itemsList = response;
    } else if (response is Map && response['users'] != null) {
      itemsList = response['users'] as List<dynamic>;
    } else {
      itemsList = [];
    }

    return itemsList.map((e) => RegisteredUserModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> createUser({
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
  }) async {
    final data = <String, dynamic>{'email': email, 'password': password, 'phoneNumber': phoneNumber, 'userRole': role};
    await _apiClient.post(ApiConstants.registerPath, data: data);
  }

  @override
  Future<void> resetUserPassword(String email, String newPassword) async {
    final data = {'email': email, 'newPassword': newPassword};
    await _apiClient.post(ApiConstants.adminResetPasswordPath, data: data);
  }

  @override
  Future<void> removeUser(String email) async {
    final data = {'email': email};
    await _apiClient.post(ApiConstants.adminRemoveUserPath, data: data);
  }

  @override
  Future<void> changeUserRole(String email, String newRole) async {
    final data = {'email': email, 'userRole': newRole};
    await _apiClient.post(ApiConstants.adminChangeRolePath, data: data);
  }
}
