// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/constants/app_constants.dart';
import 'package:surabhi/core/theme/app_themes.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/routes/app_router.dart';
import 'package:surabhi/injector.dart' as di; // di for dependency injection
import 'package:surabhi/core/theme/theme_cubit.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await di.init(); // Initialize all dependencies
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: di.sl<AuthBloc>()),
        BlocProvider<ThemeCubit>(create: (_) => di.sl<ThemeCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: AppConstants.appName,
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            routerConfig: di.sl<AppRouter>().router,
          );
        },
      ),
    );
  }
}
