// lib/injector.dart
import 'package:get_it/get_it.dart';
import 'package:local_auth/local_auth.dart';
import 'package:surabhi/core/network/api_client.dart';
import 'package:surabhi/core/services/biometric_service.dart';
import 'package:surabhi/core/services/device_id_service.dart';
import 'package:surabhi/core/services/storage_service.dart';
import 'package:surabhi/features/auth/datasources/auth_remote_datasource.dart';
import 'package:surabhi/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:surabhi/features/auth/repositories/auth_repository.dart';
import 'package:surabhi/features/admin/users/datasources/users_remote_datasource.dart' as admin_users;
import 'package:surabhi/features/admin/users/repositories/users_repository.dart' as admin_users;
import 'package:surabhi/features/admin/users/presentation/bloc/users_bloc.dart' as admin_users;
import 'package:surabhi/features/profile/datasources/profile_remote_datasource.dart';
import 'package:surabhi/features/profile/repositories/profile_repository.dart';
import 'package:surabhi/features/profile/presentation/bloc/profile_bloc.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:surabhi/core/network/api_interceptor.dart';
import 'package:surabhi/core/theme/theme_cubit.dart';
import 'package:surabhi/features/settings/presentation/bloc/settings_cubit.dart';
import 'package:surabhi/routes/app_navigator.dart';
import 'package:surabhi/routes/app_router.dart';

final sl = GetIt.instance; // sl = Service Locator

Future<void> init() async {
  // --- 1. External Dependencies (MUST be first) ---
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => LocalAuthentication());
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Dio());

  // --- 2. Core Services (Depend on External) ---
  sl.registerLazySingleton<StorageService>(() => StorageService(sl<SharedPreferences>(), sl<FlutterSecureStorage>()));
  sl.registerLazySingleton(() => BiometricService(sl(), sl()));
  sl.registerLazySingleton(() => DeviceIdService(sl<FlutterSecureStorage>()));
  sl.registerLazySingleton(() => AppNavigator());
  sl.registerLazySingleton(() => ThemeCubit(sl<StorageService>()));
  sl.registerLazySingleton<ApiInterceptor>(() => ApiInterceptor(sl()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl(), sl()));

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
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepositoryImpl(remoteDataSource: sl()));
  sl.registerFactory(() => ProfileBloc(profileRepository: sl()));

  // Admin Users
  sl.registerLazySingleton<admin_users.UsersRemoteDataSource>(
    () => admin_users.UsersRemoteDataSourceImpl(apiClient: sl()),
  );
  sl.registerLazySingleton<admin_users.UsersRepository>(() => admin_users.UsersRepositoryImpl(remoteDataSource: sl()));
  sl.registerFactory(() => admin_users.UsersBloc(usersRepository: sl()));
  // register
}
