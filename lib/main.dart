// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:surabhi/core/constants/colors.dart';
import 'package:surabhi/core/network/api_client.dart' as di;
import 'package:surabhi/core/shared_preferences/preferences_service.dart' as di;
import 'package:surabhi/features/auth/data/datasources/auth_remote_datasource.dart' as di;
import 'package:surabhi/features/auth/data/repositories/auth_repository.dart' as di;
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/routes/app_router.dart';
import 'package:surabhi/injector.dart' as di; // di for dependency injection

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init(); // Initialize all dependencies
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Provide core services that repositories depend on
        RepositoryProvider(create: (_) => di.sl<di.PreferencesService>()),
        RepositoryProvider(create: (_) => di.sl<di.ApiClient>()),
        RepositoryProvider(create: (_) => di.sl<di.AuthRemoteDataSource>()),
        RepositoryProvider(create: (_) => di.sl<di.AuthRepository>()),
      ],
      child: BlocProvider<AuthBloc>(
        // Create the AuthBloc, which uses AuthRepository
        create: (context) => di.sl<AuthBloc>(),
        // The AppStarted event is dispatched in SplashScreen to check initial auth state
        child: MaterialApp.router(
          title: 'My Mobile App',
          theme: ThemeData(
            primaryColor: AppColors.primaryColor,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.blue, width: 2.0),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Colors.grey[400]!, width: 1.0),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.red, width: 1.0),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: const BorderSide(color: Colors.red, width: 2.0),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          routerConfig: appRouter,
        ),
      ),
    );
  }
}