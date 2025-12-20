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
    if (savedTheme == AppTheme.light.name) {
      emit(ThemeMode.light);
    } else if (savedTheme == AppTheme.dark.name) {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.system);
    }
  }

  void toggleTheme(bool isDark) async {
    final newTheme = isDark ? ThemeMode.dark : ThemeMode.light;
    await _storageService.saveThemeMode(newTheme.name);
    emit(newTheme);
  }

  Future<void> setTheme(AppTheme theme) async {
    await _storageService.saveThemeMode(theme.name);

    switch (theme) {
      case AppTheme.light:
        emit(ThemeMode.light);
        break;
      case AppTheme.dark:
        emit(ThemeMode.dark);
        break;
      case AppTheme.system:
        emit(ThemeMode.system);
        break;
    }
  }
}
