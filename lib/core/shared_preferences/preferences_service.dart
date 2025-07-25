// lib/core/shared_preferences/preferences_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:surabhi/core/constants/app_constants.dart';

class PreferencesService {
  final SharedPreferences _prefs;
  final FlutterSecureStorage _secureStorage;

  PreferencesService(this._prefs, this._secureStorage);

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: AppConstants.ACCESS_TOKEN_KEY, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.ACCESS_TOKEN_KEY);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: AppConstants.REFRESH_TOKEN_KEY, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.REFRESH_TOKEN_KEY);
  }

  Future<void> saveUserRole(String role) async {
    await _prefs.setString(AppConstants.USER_ROLE_KEY, role);
  }

  String? getUserRole() {
    return _prefs.getString(AppConstants.USER_ROLE_KEY);
  }

  Future<void> clearAuthData() async {
    await _secureStorage.delete(key: AppConstants.ACCESS_TOKEN_KEY);
    await _secureStorage.delete(key: AppConstants.REFRESH_TOKEN_KEY);
    await _prefs.remove(AppConstants.USER_ROLE_KEY);
  }
}