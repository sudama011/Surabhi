// lib/injector.dart
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

// Core Imports
import 'package:surabhi/core/network/dio_factory.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/core/network/api_interceptor.dart';
import 'package:surabhi/core/services/biometric_service.dart';
import 'package:surabhi/core/services/device_id_service.dart';
import 'package:surabhi/core/services/storage_service.dart';
import 'package:surabhi/core/theme/theme_cubit.dart';
import 'package:surabhi/routes/app_navigator.dart';
import 'package:surabhi/routes/app_router.dart';

// Feature Imports
import 'package:surabhi/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:surabhi/features/auth/datasources/auth_remote_datasource.dart';
import 'package:surabhi/features/auth/repositories/auth_repository.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/features/profile/datasources/profile_remote_datasource.dart';
import 'package:surabhi/features/profile/repositories/profile_repository.dart';
import 'package:surabhi/features/profile/presentation/bloc/profile_bloc.dart';

// Home Feature Imports
import 'package:surabhi/features/home/datasources/home_remote_datasource.dart';
import 'package:surabhi/features/home/repositories/home_repository.dart';
import 'package:surabhi/features/home/presentation/bloc/home_bloc.dart';

// Admin Feature Imports (Aliased)
import 'package:surabhi/features/admin/users/datasources/users_remote_datasource.dart' as admin_users;
import 'package:surabhi/features/admin/users/repositories/users_repository.dart' as admin_users;
import 'package:surabhi/features/admin/users/presentation/bloc/users_bloc.dart' as admin_users;
import 'package:surabhi/features/admin/devotees/datasources/devotees_remote_datasource.dart' as admin_devotees;
import 'package:surabhi/features/admin/devotees/repositories/devotees_repository.dart' as admin_devotees;
import 'package:surabhi/features/admin/devotees/presentation/bloc/devotees_bloc.dart' as admin_devotees;

final sl = GetIt.instance; // Service Locator

Future<void> init() async {
  // --- 1. External Dependencies (MUST be first) ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => LocalAuthentication());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  // --- 2. Core Services (Depend on External) ---
  sl.registerLazySingleton<StorageService>(() => StorageService(sl<SharedPreferences>(), sl<FlutterSecureStorage>()));
  sl.registerLazySingleton<ApiInterceptor>(() => ApiInterceptor(sl()));
  sl.registerLazySingleton<Dio>(() => DioFactory.create(sl()));
  sl.registerLazySingleton(() => BiometricService(sl(), sl()));
  sl.registerLazySingleton(() => DeviceIdService(sl<FlutterSecureStorage>()));
  sl.registerLazySingleton(() => AppNavigator());
  sl.registerLazySingleton(() => ThemeCubit(sl<StorageService>()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  // --- 3. Features ---

  // Settings Feature
  sl.registerFactory(() => SettingsCubit(sl(), sl()));

  // Auth Feature
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl(), sl()));
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl(), sl(), sl(), sl()));
  sl.registerLazySingleton(() => AuthBloc(sl(), sl()));
  sl.registerLazySingleton(() => AppRouter(sl(), sl()));

  // Profile Feature
  sl.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(sl(), sl()));
  sl.registerFactory(() => ProfileBloc(sl(), sl()));

  // Home Feature
  sl.registerLazySingleton<HomeRemoteDataSource>(() => HomeRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(sl()));
  sl.registerFactory(() => HomeBloc(sl()));

  // Admin Users
  sl.registerLazySingleton<admin_users.UsersRemoteDataSource>(() => admin_users.UsersRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<admin_users.UsersRepository>(() => admin_users.UsersRepositoryImpl(remoteDataSource: sl()));
  sl.registerFactory(() => admin_users.UsersBloc(sl()));

  // Admin Devotees
  sl.registerLazySingleton<admin_devotees.DevoteesRemoteDataSource>(
    () => admin_devotees.DevoteesRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<admin_devotees.DevoteesRepository>(() => admin_devotees.DevoteesRepositoryImpl(sl()));
  sl.registerFactory(() => admin_devotees.DevoteesBloc(sl()));
}
