// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/features/auth/models/auth_response_model.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/core/utils/error_utils.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password, bool rememberMe);

  Future<void> sendTwoFactor(String email, String provider);

  Future<bool> verifyTwoFactor(
    String email,
    String provider,
    String code, {
    bool rememberMe,
    String preAuthRefreshToken,
  });

  Future<AuthResponseModel> refreshToken();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResponseModel> login(String email, String password, bool rememberMe) async {
    try {
      final data = {'email': email, 'password': password, 'rememberMe': rememberMe};
      final response = await apiClient.dio.post(
        ApiConstants.loginPath,
        data: data,
        options: Options(contentType: Headers.jsonContentType, extra: {'requiresAuth': false}),
      );

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      // Extract user-friendly message from API response
      final errorMessage = ErrorUtils.errorMessageFrom(e, defaultMessage: 'Invalid credentials');
      throw AuthException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<void> sendTwoFactor(String email, String provider) async {
    try {
      final data = {'email': email, 'provider': provider};
      await apiClient.dio.post(
        ApiConstants.send2FAPath,
        data: data,
        options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {
      final errorMessage = ErrorUtils.errorMessageFrom(e, defaultMessage: 'Failed to send 2FA code');
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<bool> verifyTwoFactor(
    String email,
    String provider,
    String code, {
    bool rememberMe = true,
    String preAuthRefreshToken = '',
  }) async {
    try {
      final data = {
        'email': email,
        'provider': provider,
        'code': code,
        'rememberMe': rememberMe,
        'preAuthRefreshToken': preAuthRefreshToken,
      };
      final response = await apiClient.dio.post(
        ApiConstants.verify2FAPath,
        data: data,
        options: Options(contentType: Headers.jsonContentType, extra: {'requiresAuth': false}),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      final errorMessage = ErrorUtils.errorMessageFrom(e, defaultMessage: 'Failed to verify 2FA code');
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<AuthResponseModel> refreshToken() async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.refreshPath,
        options: Options(contentType: Headers.jsonContentType),
      );

      return AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final errorMessage = ErrorUtils.errorMessageFrom(e, defaultMessage: 'Failed to refresh token');
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      // don't await this call
      apiClient.dio.post(ApiConstants.logoutPath, options: Options(contentType: Headers.jsonContentType));
    } catch (e) {
      // Logout failure is not critical, continue with local logout
    }
  }
}
