// lib/core/network/api_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/core/errors/exceptions.dart';
import 'package:surabhi/core/shared_preferences/preferences_service.dart';

class ApiClient {
  final PreferencesService _preferencesService;
  final http.Client _client;

  ApiClient(this._preferencesService, this._client);

  Future<Map<String, dynamic>> _sendRequest(
    String method,
    String url, {
    Map<String, String>? headers,
    Object? body,
    bool requiresAuth = false,
    bool isRefresh = false, // Special flag for refresh token endpoint
  }) async {
    headers ??= {};
    headers['Content-Type'] = 'application/json';

    if (requiresAuth && !isRefresh) {
      final accessToken = await _preferencesService.getAccessToken();
      if (accessToken == null) {
        throw AuthException('No access token found. Please log in.');
      }
      headers['Authorization'] = 'Bearer $accessToken';
    } else if (isRefresh) {
      // For refresh token request, use the refresh token
      final refreshToken = await _preferencesService.getRefreshToken();
      if (refreshToken == null) {
        throw AuthException('No refresh token found for refresh attempt. Please log in.');
      }
      headers['Authorization'] = 'Bearer $refreshToken';
    }

    http.Response response;
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _client.get(Uri.parse(url), headers: headers);
          break;
        case 'POST':
          response = await _client.post(Uri.parse(url), headers: headers, body: body);
          break;
        case 'PUT':
          response = await _client.put(Uri.parse(url), headers: headers, body: body);
          break;
        case 'DELETE':
          response = await _client.delete(Uri.parse(url), headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
    } on http.ClientException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    }

    // Handle responses
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      }
      return {}; // Empty response body for 2xx status
    } else if (response.statusCode == 401 && requiresAuth && !isRefresh) {
      // 401 Unauthorized, and this request required auth and wasn't a refresh request itself
      print('401 Unauthorized. Attempting to refresh token...');
      try {
        final Map<String, dynamic> refreshResponse = await _sendRequest('POST', AppConstants.REFRESH_ENDPOINT, isRefresh: true);
        final newAccessToken = refreshResponse['access_token'];
        if (newAccessToken != null) {
          await _preferencesService.saveAccessToken(newAccessToken);
          print('Token refreshed successfully. Retrying original request...');
          // Retry the original request with the new access token
          headers['Authorization'] = 'Bearer $newAccessToken';
          return await _sendRequest(method, url, headers: headers, body: body, requiresAuth: requiresAuth);
        } else {
          throw AuthException('Failed to get new access token after refresh.');
        }
      } catch (e) {
        // If refresh fails or any error during retry, force logout
        print('Token refresh or retry failed: $e');
        await _preferencesService.clearAuthData(); // Clear all tokens
        throw AuthException('Session expired. Please log in again.');
      }
    } else if (response.statusCode == 403) {
        throw PermissionDeniedException('Access forbidden: ${response.body}');
    } else {
      String errorMessage = 'Server error: ${response.statusCode}';
      try {
        errorMessage = json.decode(response.body)['message'] ?? errorMessage;
      } catch (_) {
        errorMessage = 'Server error: ${response.statusCode} - ${response.body}';
      }
      throw ServerException(errorMessage);
    }
  }

  Future<Map<String, dynamic>> get(String url, {bool requiresAuth = false}) {
    return _sendRequest('GET', url, requiresAuth: requiresAuth);
  }

  Future<Map<String, dynamic>> post(String url, {Object? body, bool requiresAuth = false}) {
    return _sendRequest('POST', url, body: body, requiresAuth: requiresAuth);
  }

  Future<Map<String, dynamic>> put(String url, {Object? body, bool requiresAuth = false}) {
    return _sendRequest('PUT', url, body: body, requiresAuth: requiresAuth);
  }

  Future<Map<String, dynamic>> delete(String url, {bool requiresAuth = false}) {
    return _sendRequest('DELETE', url, requiresAuth: requiresAuth);
  }
}