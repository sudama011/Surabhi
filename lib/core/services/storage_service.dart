// lib/core/services/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'accessToken';
  static const _accessTokenExpiryKey = 'access_token_expiry';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _refreshTokenExpiryKey = 'refresh_token_expiry';
  static const String userDataKey = 'user_data';
  static const String _themeModeKey = 'themeMode';

  StorageService(this._prefs, this._secureStorage);

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> saveTokenExpiry(DateTime expiry) async {
    await _prefs.setString(_accessTokenExpiryKey, expiry.toIso8601String());
  }

  Future<void> saveRefreshTokenExpiry(DateTime expiry) async {
    await _prefs.setString(_refreshTokenExpiryKey, expiry.toIso8601String());
  }

  DateTime? getTokenExpiry() {
    final dateStr = _prefs.getString(_accessTokenExpiryKey);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  DateTime? getRefreshTokenExpiry() {
    final dateStr = _prefs.getString(_refreshTokenExpiryKey);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  Future<void> saveUserJson(String jsonString) async {
    await _secureStorage.write(key: userDataKey, value: jsonString);
  }

  Future<String?> getUserJson() async {
    return await _secureStorage.read(key: userDataKey);
  }

  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(_themeModeKey, themeMode);
  }

  Future<String?> getThemeMode() async {
    return _prefs.getString(_themeModeKey);
  }

  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _prefs.remove(_accessTokenExpiryKey);
    await _prefs.remove(_refreshTokenExpiryKey);
  }
}
