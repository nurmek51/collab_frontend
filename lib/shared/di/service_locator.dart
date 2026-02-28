import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../api/client.dart';
import '../api/auth_api.dart';
import '../api/freelancer_api.dart';
import '../api/orders_api.dart';
import '../api/applications_api.dart';
import '../api/companies_api.dart';
import '../api/clients_api.dart';
import '../api/admin_api.dart';
import '../guards/admin_auth_guard.dart';
import '../guards/freelancer_profile_guard.dart';
import '../guards/client_guard.dart';
import '../state/auth.dart';
import '../state/freelancer_onboarding_state.dart';
import '../state/orders_state_manager.dart';
import '../services/freelancer_profile_status_manager.dart';
import '../services/freelancer_onboarding_service.dart';
import '../guards/auth_guard.dart';
import '../storage/secure_storage_service.dart';
import '../storage/preferences_service.dart';
import '../network/dio_client.dart';
import '../../core/services/api_service.dart';
import '../../core/config/app_config.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/logout.dart';

/// Service locator for dependency injection
final GetIt sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initializeDependencies() async {
  // Core services
  sl.registerLazySingleton<AuthStore>(() => AuthStore());
  sl.registerLazySingleton<FreelancerOnboardingStore>(
    () => FreelancerOnboardingStore(),
  );
  sl.registerLazySingleton<OrdersStateManager>(
    () => OrdersStateManager.instance,
  );

  // External dependencies
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl = AppConfig.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    return dio;
  });

  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<PreferencesService>(() => PreferencesService());
  sl.registerLazySingleton<DioClient>(() => DioClient(sl<Dio>()));

  // Auth domain layer
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );
  sl.registerLazySingleton(() => Logout(sl<AuthRepository>()));

  // API client
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl<AuthStore>()));

  // Core API service (singleton)
  sl.registerLazySingleton<ApiService>(() => ApiService.instance);

  // API services
  sl.registerLazySingleton<AuthApi>(
    () => AuthApi(sl<ApiClient>(), sl<AuthStore>()),
  );
  sl.registerLazySingleton<FreelancerApi>(() => FreelancerApi(sl<ApiClient>()));
  sl.registerLazySingleton<OrdersApi>(() => OrdersApi(sl<ApiClient>()));
  sl.registerLazySingleton<ApplicationsApi>(
    () => ApplicationsApi(sl<ApiClient>()),
  );
  sl.registerLazySingleton<CompaniesApi>(() => CompaniesApi(sl<ApiClient>()));
  sl.registerLazySingleton<ClientsApi>(() => ClientsApi(sl<ApiClient>()));
  sl.registerLazySingleton<AdminApi>(() => AdminApi(sl<ApiClient>()));

  // Guards
  sl.registerLazySingleton<AdminAuthGuard>(() => AdminAuthGuard(sl<AuthApi>()));
  sl.registerLazySingleton<FreelancerProfileGuard>(
    () => FreelancerProfileGuard(
      sl<FreelancerProfileStatusManager>(),
      sl<AuthStore>(),
    ),
  );
  sl.registerLazySingleton<ClientGuard>(
    () => ClientGuard(
      sl<PreferencesService>(),
      sl<AuthStore>(),
      sl<ApiService>(),
    ),
  );

  // Services
  sl.registerLazySingleton<FreelancerProfileStatusManager>(
    () => FreelancerProfileStatusManager(sl<FreelancerApi>(), sl<AuthStore>()),
  );
  sl.registerLazySingleton<FreelancerOnboardingService>(
    () => FreelancerOnboardingService(),
  );

  // Guards
  sl.registerLazySingleton<AuthGuard>(() => AuthGuard(sl<AuthStore>()));
  sl.registerLazySingleton<RoleGuard>(
    () => RoleGuard(sl<AuthStore>(), sl<FreelancerProfileStatusManager>()),
  );
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
  await initializeDependencies();
}
