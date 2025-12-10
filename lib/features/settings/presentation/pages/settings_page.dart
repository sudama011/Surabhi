// lib/features/settings/presentation/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/theme/theme_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            secondary: const Icon(Icons.brightness_6),
            title: const Text('Dark Mode'),
            value: isDark,
            onChanged: (val) => context.read<ThemeCubit>().toggleTheme(val),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => context.read<ThemeCubit>().setSystemTheme(),
            child: const Text('Use System Theme'),
          ),
        ],
      ),
    );
  }
}
