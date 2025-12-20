import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:surabhi/core/services/storage_service.dart';
import 'package:surabhi/core/theme/theme_cubit.dart';

class _StorageServiceFake implements StorageService {
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
  Future<void> saveAccessToken(String token) async {}
  @override
  Future<void> saveRefreshToken(String token) async {}
  @override
  Future<void> saveRefreshTokenExpiry(DateTime expiry) async {}
  @override
  DateTime? getRefreshTokenExpiry() => null;
  @override
  Future<void> saveUserJson(String json) async {}
  @override
  Future<String?> getUserJson() async => null;
  @override
  Future<void> saveTokenExpiry(DateTime expiry) async {}
  @override
  DateTime? getTokenExpiry() => null;
}

void main() {
  late _StorageServiceFake storageService;
  late ThemeCubit cubit;

  setUp(() {
    storageService = _StorageServiceFake();
    cubit = ThemeCubit(storageService);
  });

  test('initial emits system by default', () async {
    expect(cubit.state, ThemeMode.system);
  });

  test('toggleTheme(true) sets dark and persists', () async {
    cubit.toggleTheme(true);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(cubit.state, ThemeMode.dark);
    expect(await storageService.getThemeMode(), 'dark');
  });
}
