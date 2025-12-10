// lib/core/services/secure_token_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing and retrieving authentication tokens
class SecureTokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userRoleKey = 'user_role';
  static const String _fingerprintEnabledKey = 'fingerprint_enabled';

  final FlutterSecureStorage _storage;

  SecureTokenStorage({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Save user role
  Future<void> saveUserRole(String role) async {
    await _storage.write(key: _userRoleKey, value: role);
  }

  /// Get user role
  Future<String?> getUserRole() async {
    return await _storage.read(key: _userRoleKey);
  }

  /// Enable fingerprint authentication
  Future<void> enableFingerprint() async {
    await _storage.write(key: _fingerprintEnabledKey, value: 'true');
  }

  /// Disable fingerprint authentication
  Future<void> disableFingerprint() async {
    await _storage.write(key: _fingerprintEnabledKey, value: 'false');
  }

  /// Check if fingerprint is enabled
  Future<bool> isFingerprintEnabled() async {
    final value = await _storage.read(key: _fingerprintEnabledKey);
    return value == 'true';
  }

  /// Clear all tokens and settings
  Future<void> clearAll() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userRoleKey),
      _storage.delete(key: _fingerprintEnabledKey),
    ]);
  }

  /// Check if tokens exist
  Future<bool> hasTokens() async {
    final accessToken = await getAccessToken();
    final refreshToken = await getRefreshToken();
    return accessToken != null && refreshToken != null;
  }
}
