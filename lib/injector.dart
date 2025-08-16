// lib/injector.dart
import 'package:get_it/get_it.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/core/shared_preferences/preferences_service.dart';
import 'package:surabhi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:surabhi/features/auth/data/repositories/auth_repository.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/features/users/data/datasources/users_remote_datasource.dart';
import 'package:surabhi/features/users/data/repositories/users_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:surabhi/core/network/api_interceptor.dart';
import 'package:surabhi/core/theme/theme_cubit.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // --- External Dependencies (MUST be first) ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // --- Core ---
  sl.registerLazySingleton<PreferencesService>(
    () => PreferencesService(sl(), sl()),
  );

  sl.registerLazySingleton(() => ThemeCubit(sl()));

  
  // ApiClient needs the PreferencesService to be available
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(sl()),
  );

  // Register the Dio instance directly from the ApiClient
  sl.registerLazySingleton<Dio>(() => sl<ApiClient>().dio);

  // Now, configure the interceptor.
  sl.registerLazySingleton<ApiInterceptor>(() => ApiInterceptor(dio: sl(), preferencesService: sl()));
  
  // Finally, add the interceptor to the Dio instance.
  sl<Dio>().interceptors.add(sl<ApiInterceptor>());

  // --- Features ---
  
  // Auth
  sl.registerFactory(() => AuthBloc(authRepository: sl()));
  
  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), preferencesService: sl()),
  );
  
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl()),
  );
  
  // Users
  sl.registerLazySingleton<UsersRepository>(() => UsersRepository(sl()));
  sl.registerLazySingleton<UsersRemoteDataSource>(() => UsersRemoteDataSourceImpl(sl()));

}