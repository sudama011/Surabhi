// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import 'package:surabhi/core/errors/exceptions.dart';

/// A wrapper around Dio that abstracts network complexity.
///
/// Usage:
/// await apiClient.get('/users', requiresAuth: true);
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters, bool requiresAuth = true}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters, options: _getOptions(requiresAuth));
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _getOptions(requiresAuth),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _getOptions(requiresAuth),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _getOptions(requiresAuth),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool requiresAuth = true,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _getOptions(requiresAuth),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ---------------------------------------------------------------------------
  // PRIVATE HELPERS
  // ---------------------------------------------------------------------------

  /// Helper to create Options based on the [requiresAuth] flag.
  Options _getOptions(bool requiresAuth) {
    return Options(extra: {'requiresAuth': requiresAuth});
  }

  /// Centralized error handling.
  /// Converts DioException into App-specific Exceptions.
  Exception _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const ServerException(message: 'Connection timed out. Please check your internet connection.');
      case DioExceptionType.connectionError:
        return const ServerException(message: 'No internet connection. Please check your settings.');
      case DioExceptionType.badCertificate:
        return const ServerException(message: 'Secure connection failed (Certificate Error).');
      case DioExceptionType.cancel:
        return const ServerException(message: 'Request cancelled.');
      case DioExceptionType.unknown:
        if (e.error.toString().contains('SocketException')) {
          return const ServerException(message: 'Network unreachable. Please check your connection.');
        }
        break;
      default:
        break;
    }
    // 2. Extract the specific error message from the backend JSON (if available)
    //    or fall back to a generic Status Code message.
    final String errorMessage =
        _extractMessageFromResponse(e.response) ??
        _getMessageForStatusCode(e.response?.statusCode) ??
        e.message ??
        'An unexpected error occurred.';

    // 3. Return the specific Exception based on Status Code
    final statusCode = e.response?.statusCode;

    if (statusCode == 401) {
      return AuthException(message: errorMessage);
    }

    if (statusCode == 403) {
      return PermissionDeniedException(message: errorMessage);
    }

    // Default to ServerException for everything else (400, 404, 500, etc.)
    return ServerException(message: errorMessage);
  }

  /// Extracts "message", "error", or "errors" from the API response body.
  String? _extractMessageFromResponse(Response? response) {
    try {
      final data = response?.data;

      if (data != null && data is Map<String, dynamic>) {
        if (data.containsKey('message')) return data['message']?.toString();
        if (data.containsKey('error')) return data['error']?.toString();

        // Handle Laravel/Rails style validation errors: { "errors": { "email": ["Invalid"] } }
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is Map && errors.isNotEmpty) {
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) return firstError.first.toString();
            return firstError.toString();
          }
          if (errors is List && errors.isNotEmpty) return errors.first.toString();
        }
      }
    } catch (_) {
      // Ignore parsing errors and return null
    }
    return null;
  }

  /// Fallback messages if the server didn't send a specific JSON error message.
  String? _getMessageForStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication failed. Please login again.';
      case 403:
        return 'Access denied.';
      case 404:
        return 'Resource not found.';
      case 405:
        return 'Method not allowed.';
      case 409:
        return 'Conflict. The resource already exists.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please wait a moment.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return null;
    }
  }
}
