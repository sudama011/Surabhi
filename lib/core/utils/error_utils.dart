// lib/core/utils/error_utils.dart

import 'package:dio/dio.dart';

class ErrorUtils {
  /// Extracts a custom message from the API response body.
  /// Returns [null] if no specific message is found, allowing the caller
  /// to fall back to status codes.
  static String? extractErrorMessage(DioException error) {
    try {
      final data = error.response?.data;

      if (data != null && data is Map<String, dynamic>) {
        // Check for common error keys
        if (data.containsKey('message')) {
          return data['message']?.toString();
        }
        if (data.containsKey('error')) {
          return data['error']?.toString();
        }
        // Handle validation errors (often formatted as { "errors": { "field": ["msg"] } })
        if (data.containsKey('errors')) {
          final errors = data['errors'];
          if (errors is Map && errors.isNotEmpty) {
            // Return the first validation error found
            final firstError = errors.values.first;
            if (firstError is List && firstError.isNotEmpty) {
              return firstError.first.toString();
            }
            return firstError.toString();
          }
          if (errors is List && errors.isNotEmpty) {
            return errors.first.toString();
          }
        }
      }
    } catch (_) {
      // If parsing fails, ignore and return null
    }
    return null;
  }

  static String getErrorMessageByStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Invalid request. Please check your input.';
      case 401:
        return 'Authentication failed. Please login again.';
      case 403:
        return 'Access denied. You don\'t have permission for this action.';
      case 404:
        return 'Resource not found.';
      case 409:
        return 'Conflict. The resource already exists.';
      case 422:
        return 'Validation failed. Please check your input.';
      case 429:
        return 'Too many requests. Please wait a moment.';
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Service temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        return 'An unexpected error occurred.';
    }
  }

  /// Main entry point to get a user-friendly error message.
  ///
  /// Priority:
  /// 1. Network/Connection Type Errors (No Internet, Timeout)
  /// 2. Server-provided custom message (e.g. "Email already taken")
  /// 3. Standard Status Code message (e.g. "404 Not Found")
  /// 4. Default fallback message
  static String errorMessageFrom(
    DioException error, {
    String defaultMessage = 'Something went wrong. Please try again.',
  }) {
    // 1. Handle Connectivity & System Errors
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timed out. Please check your internet connection.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your settings.';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      case DioExceptionType.badCertificate:
        return 'Secure connection failed (Certificate Error).';
      case DioExceptionType.badResponse:
        // Logic continues below for 4xx/5xx responses
        break;
      case DioExceptionType.unknown:
        if (error.error.toString().contains('SocketException')) {
          return 'Network unreachable. Please check your connection.';
        }
        break;
    }

    // 2. Try to get specific message from API
    final apiMessage = extractErrorMessage(error);
    if (apiMessage != null && apiMessage.isNotEmpty) {
      return apiMessage;
    }

    // 3. Fallback to Status Code Message
    if (error.response?.statusCode != null) {
      return getErrorMessageByStatusCode(error.response?.statusCode);
    }

    // 4. Final Fallback
    return defaultMessage;
  }
}
