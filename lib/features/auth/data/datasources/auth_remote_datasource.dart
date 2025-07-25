// lib/features/auth/data/datasources/auth_remote_datasource.dart
import 'dart:convert';
import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login(String email, String password);
  Future<void> register(String email, String password, String role);
  Future<UserModel> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final response = await apiClient.post(
      AppConstants.LOGIN_ENDPOINT,
      body: json.encode({'email': email, 'password': password}),
    );
    return AuthResponseModel.fromJson(response);
  }

  @override
  Future<void> register(String email, String password, String role) async {
    // The Python API's register endpoint currently returns a simple message.
    // If it were to return a full user model, you'd parse it here.
    await apiClient.post(
      AppConstants.REGISTER_ENDPOINT,
      body: json.encode({'email': email, 'password': password, 'role': role}),
    );
    // Assuming 201 Created on success
  }

  @override
  Future<UserModel> getProfile() async {
    final response = await apiClient.get(
      AppConstants.PROFILE_ENDPOINT,
      requiresAuth: true,
    );
    return UserModel.fromJson(response);
  }
}