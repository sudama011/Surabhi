import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/core/theme/theme_cubit.dart';
import 'package:surabhi/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:surabhi/injector.dart' as di;

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the Cubit locally since it's only used here (mostly)
    return BlocProvider(create: (context) => di.sl<SettingsCubit>()..loadSettings(), child: const _SettingsView());
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.status == SettingsStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!), backgroundColor: Theme.of(context).colorScheme.error),
          );
        }
      },
      builder: (context, state) {
        if (state.status == SettingsStatus.loading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- APPEARANCE ---
            const _SectionHeader(title: 'Appearance'),
            const _ThemeDropdownCard(),

            const SizedBox(height: 24),

            // --- SECURITY ---
            const _SectionHeader(title: 'Security'),
            if (state.isBiometricSupported)
              Card(
                child: SwitchListTile(
                  secondary: const Icon(Icons.fingerprint),
                  title: const Text('Biometric Login'),
                  subtitle: const Text('Use fingerprint or FaceID to log in'),
                  value: state.isBiometricEnabled,
                  onChanged: (value) {
                    context.read<SettingsCubit>().toggleBiometric(value);
                  },
                  activeColor: Theme.of(context).primaryColor,
                ),
              )
            else
              const Card(
                child: ListTile(
                  leading: Icon(Icons.fingerprint_outlined, color: Colors.grey),
                  title: Text('Biometric Login'),
                  subtitle: Text('Not available on this device'),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ThemeDropdownCard extends StatelessWidget {
  const _ThemeDropdownCard();

  AppTheme _getAppThemeFromMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppTheme.light;
      case ThemeMode.dark:
        return AppTheme.dark;
      case ThemeMode.system:
        return AppTheme.system;
    }
  }

  String _getThemeDisplayName(AppTheme theme) {
    switch (theme) {
      case AppTheme.light:
        return 'Light Mode';
      case AppTheme.dark:
        return 'Dark Mode';
      case AppTheme.system:
        return 'System Default';
    }
  }

  @override
  Widget build(BuildContext context) {
    // We watch ThemeCubit here to update the Dropdown value
    final themeMode = context.watch<ThemeCubit>().state;
    final currentAppTheme = _getAppThemeFromMode(themeMode);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.palette_outlined),
        title: const Text('App Theme'),
        trailing: DropdownButtonHideUnderline(
          child: DropdownButton<AppTheme>(
            value: currentAppTheme,
            borderRadius: BorderRadius.circular(12),
            onChanged: (AppTheme? newTheme) {
              if (newTheme != null) {
                context.read<ThemeCubit>().setTheme(newTheme);
              }
            },
            items: AppTheme.values.map((theme) {
              return DropdownMenuItem(
                value: theme,
                child: Text(_getThemeDisplayName(theme), style: const TextStyle(fontWeight: FontWeight.w500)),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}
