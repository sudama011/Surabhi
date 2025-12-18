// lib/features/auth/datasources/auth_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/core/services/device_id_service.dart';
import 'package:surabhi/features/auth/models/auth_response_model.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/core/utils/error_utils.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);

  Future<void> sendTwoFactor(String email, String provider, String preAuthRefreshToken);

  Future<AuthResponseModel> verifyTwoFactor(String email, String provider, String code, String preAuthRefreshToken);

  Future<AuthResponseModel> refreshToken(String refreshToken);

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  final DeviceIdService deviceIdService;

  AuthRemoteDataSourceImpl(this.apiClient, this.deviceIdService);

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    try {
      final data = {'email': email, 'password': password, 'deviceId': await deviceIdService.getDeviceId()};
      final response = await apiClient.dio.post(
        ApiConstants.loginPath,
        data: data,
        options: Options(extra: {'requiresAuth': false}),
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
  Future<void> sendTwoFactor(String email, String provider, String preAuthRefreshToken) async {
    try {
      final data = {'email': email, 'provider': provider, 'preAuthRefreshToken': preAuthRefreshToken};
      await apiClient.dio.post(
        ApiConstants.send2FAPath,
        data: data,
        options: Options(extra: {'requiresAuth': false}),
      );
    } on DioException catch (e) {
      final errorMessage = ErrorUtils.errorMessageFrom(e, defaultMessage: 'Failed to send 2FA code');
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<AuthResponseModel> verifyTwoFactor(
    String email,
    String provider,
    String code,
    String preAuthRefreshToken,
  ) async {
    try {
      final data = {
        'email': email,
        'provider': provider,
        'code': code,
        'rememberClient': true,
        'preAuthRefreshToken': preAuthRefreshToken,
        'deviceId': await deviceIdService.getDeviceId(),
      };
      final response = await apiClient.dio.post(
        ApiConstants.verify2FAPath,
        data: data,
        options: Options(extra: {'requiresAuth': false}),
      );

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      final errorMessage = ErrorUtils.errorMessageFrom(e, defaultMessage: 'Failed to verify 2FA code');
      throw ServerException(message: errorMessage);
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    try {
      final response = await apiClient.dio.post(
        ApiConstants.refreshPath,
        data: {'refreshToken': refreshToken},
        options: Options(extra: {'requiresAuth': false}),
      );

      return AuthResponseModel.fromJson(response.data);
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
      apiClient.dio.post(ApiConstants.logoutPath);
    } catch (e) {
      // Logout failure is not critical, continue with local logout
    }
  }
}
