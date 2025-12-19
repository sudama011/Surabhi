// lib/core/network/api_interceptor.dart

import 'package:dio/dio.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/services/storage_service.dart';

class ApiInterceptor extends Interceptor {
  final StorageService _storageService;

  ApiInterceptor(this._storageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final requiresAuth = options.extra['requiresAuth'] as bool? ?? true;

    if (requiresAuth) {
      final accessToken = await _storageService.getAccessToken();
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
