// lib/core/network/api_interceptor.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/shared_preferences/preferences_service.dart';

class ApiInterceptor extends Interceptor {
  final Dio _dio;
  final PreferencesService _preferencesService;

  ApiInterceptor({required Dio dio, required PreferencesService preferencesService})
    : _dio = dio,
      _preferencesService = preferencesService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Check if the request requires authentication
    final requiresAuth = options.extra['requiresAuth'] as bool? ?? true;

    if (requiresAuth) {
      final accessToken = await _preferencesService.getAccessToken();
      if (accessToken == null) {
        return handler.reject(
          DioException(
            requestOptions: options,
            error: const AuthException(message: 'No access token found. Please log in.'),
            type: DioExceptionType.cancel,
          ),
        );
      }
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final originalRequest = err.requestOptions;
    final requiresAuth = originalRequest.extra['requiresAuth'] as bool? ?? true;

    // Check for a 401 Unauthorized error and if the request requires authentication
    if (err.response?.statusCode == 401 && requiresAuth) {
      try {
        final refreshResponse = await _refreshAccessToken();
        final newAccessToken = refreshResponse['access_token'];

        if (newAccessToken != null) {
          await _preferencesService.saveAccessToken(newAccessToken);

          // Retry the original request with the new token
          originalRequest.headers['Authorization'] = 'Bearer $newAccessToken';
          final response = await _dio.fetch(originalRequest);
          return handler.resolve(response);
        } else {
          await _preferencesService.clearAuthData();
          return handler.reject(
            DioException(
              requestOptions: originalRequest,
              error: const AuthException(message: 'Failed to get new access token.'),
              type: DioExceptionType.cancel,
            ),
          );
        }
      } catch (e) {
        // If token refresh fails, clear auth data and reject
        await _preferencesService.clearAuthData();
        return handler.reject(
          DioException(
            requestOptions: originalRequest,
            error: const AuthException(message: 'Session expired. Please log in again.'),
            type: DioExceptionType.cancel,
          ),
        );
      }
    } else if (err.response?.statusCode == 403) {
      return handler.reject(
        DioException(
          requestOptions: originalRequest,
          error: const PermissionDeniedException(message: 'Access forbidden.'),
          type: DioExceptionType.cancel,
        ),
      );
    } else if (err.type == DioExceptionType.unknown) {
      // This handles http.ClientException and other network errors
      return handler.reject(
        DioException(
          requestOptions: originalRequest,
          error: const NetworkException(message: 'Network error.'),
          type: DioExceptionType.unknown,
        ),
      );
    }

    // For all other errors, pass them along
    return handler.next(err);
  }

  Future<Map<String, dynamic>> _refreshAccessToken() async {
    final refreshToken = await _preferencesService.getRefreshToken();
    if (refreshToken == null) {
      throw const AuthException(message: 'No refresh token found.');
    }

    final refreshTokenPath = ApiConstants.refreshPath;
    final body = json.encode({'refresh_token': refreshToken});

    try {
      final response = await _dio.post(
        refreshTokenPath,
        data: body,
        // Pass a flag to prevent infinite loops during refresh
        options: Options(extra: {'requiresAuth': false}),
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw ServerException(message: 'Failed to refresh token: ${response.statusCode}');
      }
    } on DioException {
      throw const AuthException(message: 'Failed to refresh token.');
    }
  }
}
