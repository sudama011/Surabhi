// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/core/shared_preferences/preferences_service.dart';
import 'package:surabhi/core/network/api_interceptor.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(PreferencesService preferencesService)
      : _dio = Dio(
          BaseOptions(
            baseUrl: '${ApiConstants.baseApiUrl}${ApiConstants.apiVersionPath}',
            connectTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            followRedirects: false,
            receiveDataWhenStatusError: true,
          ),
        ) {
    _dio.interceptors.add(
      ApiInterceptor(dio: _dio, preferencesService: preferencesService),
    );
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
      ),
    );
  }

  // Public getter to allow features to access the configured Dio instance.
  Dio get dio => _dio;
}