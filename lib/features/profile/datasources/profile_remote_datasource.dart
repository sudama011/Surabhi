// lib/features/profile/datasources/profile_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/core/models/user_model.dart';
import 'package:surabhi/core/network/api_client.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<void> uploadAvatar(List<int> fileBytes, String fileName);
  Future<void> changePassword(String oldPassword, String newPassword);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl(this.apiClient);

  @override
  Future<UserModel> getProfile() async {
    final response = await apiClient.get(ApiConstants.userProfilePath);
    return UserModel.fromJson(response);
  }

  @override
  Future<void> uploadAvatar(List<int> fileBytes, String fileName) async {
    final formData = FormData.fromMap({'File': MultipartFile.fromBytes(fileBytes, filename: fileName)});
    await apiClient.post(ApiConstants.uploadAvatarPath, data: formData);
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    await apiClient.post(
      ApiConstants.changePasswordPath,
      data: {'oldPassword': oldPassword, 'newPassword': newPassword},
    );
  }
}
