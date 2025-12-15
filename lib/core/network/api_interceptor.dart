// lib/core/network/api_interceptor.dart

import 'package:dio/dio.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/services/preferences_service.dart';

class ApiInterceptor extends Interceptor {
  final PreferencesService _preferencesService;

  ApiInterceptor({required PreferencesService preferencesService}) : _preferencesService = preferencesService;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final requiresAuth = options.extra['requiresAuth'] as bool? ?? true;

    if (requiresAuth) {
      final accessToken = await _preferencesService.getAccessToken();
      if (accessToken == null) {
        return handler.reject(
          DioException(
            requestOptions: options,
            error: const AuthException(message: 'No access token found.'),
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
    return handler.next(err);
  }
}
