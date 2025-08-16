// lib/injector.dart
import 'package:get_it/get_it.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/core/shared_preferences/preferences_service.dart';
import 'package:surabhi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:surabhi/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:surabhi/features/auth/domain/repositories/auth_repository.dart';
import 'package:surabhi/features/auth/domain/usecases/login_usecase.dart';
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
  // --- 1. External Dependencies (MUST be first) ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Dio());

  // --- 2. Core Services (Depend on External) ---
  sl.registerLazySingleton<PreferencesService>(() => PreferencesService(sl(), sl()));
  sl.registerLazySingleton<ApiInterceptor>(() => ApiInterceptor(dio: sl(), preferencesService: sl()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<Dio>(), sl<ApiInterceptor>()));
  sl.registerLazySingleton(() => ThemeCubit(sl()));

  // --- 3. Features ---
  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(remoteDataSource: sl(), preferencesService: sl()));
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));
  sl.registerFactory(() => AuthBloc(authRepository: sl(), loginUseCase: sl()));

  // Users
  sl.registerLazySingleton<UsersRepository>(() => UsersRepository(sl()));
  sl.registerLazySingleton<UsersRemoteDataSource>(() => UsersRemoteDataSourceImpl(sl()));
}
