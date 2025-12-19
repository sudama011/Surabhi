import 'package:dio/dio.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/models/user_model.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/core/utils/error_utils.dart';

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
    try {
      final response = await apiClient.dio.get(ApiConstants.userProfilePath);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = ErrorUtils.errorMessageFrom(e, defaultMessage: 'Failed to fetch profile');
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<void> uploadAvatar(List<int> fileBytes, String fileName) async {
    try {
      final formData = FormData.fromMap({'File': MultipartFile.fromBytes(fileBytes, filename: fileName)});

      await apiClient.dio.post(
        ApiConstants.uploadAvatarPath,
        data: formData,
        options: Options(contentType: Headers.multipartFormDataContentType),
      );
    } on DioException catch (e) {
      final errorMessage = ErrorUtils.errorMessageFrom(e, defaultMessage: 'Failed to upload avatar');
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await apiClient.dio.post(
        ApiConstants.changePasswordPath,
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );
    } on DioException catch (e) {
      final errorMessage = ErrorUtils.errorMessageFrom(e, defaultMessage: 'Failed to change password');
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
