import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:surabhi/core/constants/api_constants.dart';
import 'package:surabhi/core/network/api_interceptor.dart';

class DioFactory {
  /// Creates a configured Dio instance.
  ///
  /// [apiInterceptor] is injected so we don't depend on Service Locator here.
  static Dio create(ApiInterceptor apiInterceptor) {
    final dio = Dio();

    dio.options.baseUrl = '${ApiConstants.baseApiUrl}${ApiConstants.apiVersionPath}';

    dio.options.headers = {'Accept': 'application/json', 'Content-Type': 'application/json'};

    // Web platform needs longer timeouts due to CORS preflight requests
    if (kIsWeb) {
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.sendTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);
    } else {
      dio.options.connectTimeout = const Duration(seconds: 20);
      dio.options.sendTimeout = const Duration(seconds: 10);
      dio.options.receiveTimeout = const Duration(seconds: 10);
    }

    dio.options.followRedirects = false;
    dio.options.receiveDataWhenStatusError = true;

    // Add our custom interceptor (Auth logic)
    dio.interceptors.add(apiInterceptor);

    // Add Logger (Easy debugging)
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );

    return dio;
  }
}
