// lib/features/auth/datasources/auth_remote_datasource.dart

import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/core/services/device_id_service.dart';
import 'package:surabhi/features/auth/models/auth_response_model.dart';
import 'package:surabhi/core/constants/api_constants.dart';

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
    final data = {'email': email, 'password': password, 'deviceId': await deviceIdService.getDeviceId()};
    final response = await apiClient.post(ApiConstants.loginPath, data: data, requiresAuth: false);

    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<void> sendTwoFactor(String email, String provider, String preAuthRefreshToken) async {
    final data = {'email': email, 'provider': provider, 'preAuthRefreshToken': preAuthRefreshToken};
    await apiClient.post(ApiConstants.send2FAPath, data: data, requiresAuth: false);
  }

  @override
  Future<AuthResponseModel> verifyTwoFactor(
    String email,
    String provider,
    String code,
    String preAuthRefreshToken,
  ) async {
    final data = {
      'email': email,
      'provider': provider,
      'code': code,
      'rememberClient': true,
      'preAuthRefreshToken': preAuthRefreshToken,
      'deviceId': await deviceIdService.getDeviceId(),
    };
    final response = await apiClient.post(ApiConstants.verify2FAPath, data: data, requiresAuth: false);

    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<AuthResponseModel> refreshToken(String refreshToken) async {
    final response = await apiClient.post(
      ApiConstants.refreshPath,
      data: {'refreshToken': refreshToken},
      requiresAuth: false,
    );

    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post(ApiConstants.logoutPath);
    } catch (e) {
      // Logout failure is not critical, continue with local logout
    }
  }
}
