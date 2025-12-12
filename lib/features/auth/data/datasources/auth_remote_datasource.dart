// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'package:dio/dio.dart';
import 'package:surabhi/features/auth/data/models/user_model.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/features/auth/data/models/auth_response_model.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/features/auth/domain/usecases/login_usecase.dart';
import 'package:surabhi/core/utils/error_utils.dart';

abstract class AuthRemoteDataSource {
  /// Login with email and password
  /// If 2FA is required, provide twoFactorCode in the second attempt
  Future<AuthResponseModel> login(LoginParams params);

  /// Get user profile information
  /// Requires email parameter as the API endpoint needs it
  Future<UserModel?> getUserProfile(String email);

  /// Send 2FA code via email or phone
  Future<void> sendTwoFactor(String email, String provider);

  /// Verify 2FA code
  Future<bool> verifyTwoFactor(String email, String provider, String code, {bool rememberMe = false});

  /// Refresh access token using refresh token
  Future<AuthResponseModel> refreshToken();

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResponseModel> login(LoginParams params) async {
    try {
      final data = {'email': params.email, 'password': params.password, 'rememberMe': true};
      final response = await apiClient.dio.post(
        ApiConstants.loginPath,
        data: data,
        options: Options(contentType: Headers.jsonContentType, extra: {'requiresAuth': false}),
      );

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      // Extract user-friendly message from API response
      final errorMessage = ErrorUtils.getComprehensiveErrorMessage(e, 'Login failed');
      throw AuthException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<UserModel?> getUserProfile(String email) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.userProfilePath,
        queryParameters: {'email': email},
        options: Options(contentType: Headers.jsonContentType),
      );

      if (response.statusCode == 200 && response.data != null) {
        return UserModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      final errorMessage = ErrorUtils.getComprehensiveErrorMessage(e, 'Failed to fetch profile');
      throw ServerException(message: errorMessage);
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
      final errorMessage = ErrorUtils.getComprehensiveErrorMessage(e, 'Failed to send 2FA code');
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<bool> verifyTwoFactor(String email, String provider, String code, {bool rememberMe = false}) async {
    try {
      final data = {'email': email, 'provider': provider, 'code': code, 'rememberMe': rememberMe};
      final response = await apiClient.dio.post(
        ApiConstants.verify2FAPath,
        data: data,
        options: Options(contentType: Headers.jsonContentType, extra: {'requiresAuth': false}),
      );

      return response.statusCode == 200;
    } on DioException catch (e) {
      final errorMessage = ErrorUtils.getComprehensiveErrorMessage(e, 'Failed to verify 2FA code');
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
      final errorMessage = ErrorUtils.getComprehensiveErrorMessage(e, 'Failed to refresh token');
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.dio.post(ApiConstants.logoutPath, options: Options(contentType: Headers.jsonContentType));
    } catch (e) {
      // Logout failure is not critical, continue with local logout
    }
  }
}
