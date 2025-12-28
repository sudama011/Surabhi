import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/core/services/storage_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final StorageService _storageService;

  ThemeCubit(this._storageService) : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedTheme = await _storageService.getThemeMode();
    if (savedTheme == ThemeMode.light.name) {
      emit(ThemeMode.light);
    } else if (savedTheme == ThemeMode.dark.name) {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.system);
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    final newTheme = isDark ? ThemeMode.dark : ThemeMode.light;
    await _storageService.saveThemeMode(newTheme.name);
    emit(newTheme);
  }

  Future<void> setTheme(ThemeMode theme) async {
    await _storageService.saveThemeMode(theme.name);
    emit(theme);
  }
}
