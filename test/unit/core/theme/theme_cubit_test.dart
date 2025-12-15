import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surabhi/core/services/preferences_service.dart';
import 'package:surabhi/core/theme/theme_cubit.dart';

class _PrefsFake implements PreferencesService {
  String? _theme;
  @override
  Future<String?> getThemeMode() async => _theme;
  @override
  Future<void> saveThemeMode(String themeMode) async {
    _theme = themeMode;
  }

  // Unused in these tests; simple stubs
  @override
  Future<void> clearAuthData() async {}
  @override
  Future<String?> getAccessToken() async => null;
  @override
  Future<String?> getRefreshToken() async => null;
  @override
  String? getUserJson() => null;
  @override
  Future<void> saveAccessToken(String token) async {}
  @override
  Future<void> saveRefreshToken(String token) async {}
  @override
  Future<void> saveUserJson(String json) async {}
  @override
  Future<void> enableBiometric(String refreshToken) async {}
  @override
  Future<void> disableBiometric() async {}
  @override
  Future<bool> get isBiometricEnabled async => false;
  @override
  Future<void> saveTokenExpiry(DateTime expiry) async {}
  @override
  DateTime? getTokenExpiry() => null;
}

void main() {
  late _PrefsFake prefs;
  late ThemeCubit cubit;

  setUp(() {
    prefs = _PrefsFake();
    cubit = ThemeCubit(prefs);
  });

  test('initial emits system by default', () async {
    expect(cubit.state, ThemeMode.system);
  });

  test('toggleTheme(true) sets dark and persists', () async {
    cubit.toggleTheme(true);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state, ThemeMode.dark);
    expect(await prefs.getThemeMode(), 'dark');
  });

  test('setSystemTheme persists system', () async {
    cubit.setSystemTheme();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state, ThemeMode.system);
    expect(await prefs.getThemeMode(), 'system');
  });
}
