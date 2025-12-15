// lib/core/services/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PreferencesService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'accessToken';
  static const _accessTokenExpiryKey = 'access_token_expiry';
  static const String _refreshTokenKey = 'refreshToken';
  static const String _biometricEnabledKey = 'is_biometric_enabled';
  static const String _userJsonKey = 'userJson';
  static const String _themeModeKey = 'themeMode';

  PreferencesService(this._prefs, this._secureStorage);

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

  Future<void> enableBiometric(String refreshToken) async {
    await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
  }

  Future<void> disableBiometric() async {
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.write(key: _biometricEnabledKey, value: 'false');
  }

  Future<bool> get isBiometricEnabled async {
    final val = await _secureStorage.read(key: _biometricEnabledKey);
    return val == 'true';
  }

  Future<void> saveTokenExpiry(DateTime expiry) async {
    await _prefs.setString(_accessTokenExpiryKey, expiry.toIso8601String());
  }

  DateTime? getTokenExpiry() {
    final dateStr = _prefs.getString(_accessTokenExpiryKey);
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(_themeModeKey, themeMode);
  }

  Future<String?> getThemeMode() async {
    return _prefs.getString(_themeModeKey);
  }

  Future<void> saveUserJson(String json) async {
    await _prefs.setString(_userJsonKey, json);
  }

  String? getUserJson() {
    return _prefs.getString(_userJsonKey);
  }

  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _biometricEnabledKey);
    await _prefs.remove(_userJsonKey);
  }
}
