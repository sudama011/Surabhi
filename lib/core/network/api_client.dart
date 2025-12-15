// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/core/network/api_interceptor.dart';

class ApiClient {
  final Dio _dio;

  ApiClient(this._dio, ApiInterceptor apiInterceptor) {
    _dio.options.baseUrl = '${ApiConstants.baseApiUrl}${ApiConstants.apiVersionPath}';

    // Web platform needs longer timeouts due to CORS preflight requests
    if (kIsWeb) {
      _dio.options.connectTimeout = const Duration(seconds: 30);
      _dio.options.sendTimeout = const Duration(seconds: 30);
      _dio.options.receiveTimeout = const Duration(seconds: 30);
    } else {
      _dio.options.connectTimeout = const Duration(seconds: 20);
      _dio.options.sendTimeout = const Duration(seconds: 10);
      _dio.options.receiveTimeout = const Duration(seconds: 10);
    }

    _dio.options.headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      // Add CORS headers for web
      if (kIsWeb) 'Access-Control-Allow-Origin': '*',
    };
    _dio.options.followRedirects = false;
    _dio.options.receiveDataWhenStatusError = true;

    _dio.interceptors.add(apiInterceptor);

    _dio.interceptors.add(
      PrettyDioLogger(requestHeader: true, requestBody: true, responseHeader: true, responseBody: true),
    );
  }

  Dio get dio => _dio;
}
