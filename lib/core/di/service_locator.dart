import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

// Core services
import '../../core/services/api_service.dart';
import '../../core/services/background_refresh_manager.dart';

// Auth feature
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/send_otp.dart';
import '../../features/auth/domain/usecases/verify_otp.dart';
import '../../features/auth/domain/usecases/set_role.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/refresh_token.dart';
import '../../features/auth/domain/usecases/check_auth_status.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';

// Orders feature
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/domain/usecases/get_my_orders.dart';
import '../../features/orders/domain/usecases/get_order_details.dart';
import '../../features/orders/domain/usecases/create_order.dart';
import '../../features/orders/presentation/cubit/orders_cubit.dart';
import '../../features/orders/presentation/cubit/order_details_cubit.dart';

// Profile feature
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';

// Shared
import '../../shared/storage/secure_storage_service.dart';
import '../../shared/storage/preferences_service.dart';
import '../../shared/network/dio_client.dart';
import '../../shared/network/interceptors/auth_interceptor.dart';

final GetIt sl = GetIt.instance;

/// Initialize all dependencies using clean architecture
Future<void> initializeDependencies() async {
  // ===============================
  // External
  // ===============================

  // Dio client
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl = 'https://api.collab-app.com';
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    return dio;
  });

  // Storage services
  sl.registerLazySingleton<SecureStorageService>(() => SecureStorageService());
  sl.registerLazySingleton<PreferencesService>(() => PreferencesService());

  // ===============================
  // Core
  // ===============================

  sl.registerLazySingleton<DioClient>(() => DioClient(sl<Dio>()));
  sl.registerLazySingleton<ApiService>(() => ApiService.instance);
  sl.registerLazySingleton<BackgroundRefreshManager>(
    () => BackgroundRefreshManager.instance,
  );

  // ===============================
  // Auth Feature
  // ===============================

  // Datasources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      secureStorage: sl<SecureStorageService>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SendOtp(sl<AuthRepository>()));
  sl.registerLazySingleton(() => VerifyOtp(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SetRole(sl<AuthRepository>()));
  sl.registerLazySingleton(() => Logout(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RefreshToken(sl<AuthRepository>()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl<AuthRepository>()));

  // Cubit
  sl.registerFactory(
    () => AuthCubit(
      authRepository: sl<AuthRepository>(),
      backgroundRefreshManager: sl<BackgroundRefreshManager>(),
    ),
  );

  // ===============================
  // Orders Feature
  // ===============================

  // Repositories
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(sl<ApiService>()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetMyOrders(sl<OrdersRepository>()));
  sl.registerLazySingleton(() => GetOrderDetails(sl<OrdersRepository>()));
  sl.registerLazySingleton(() => CreateOrder(sl<OrdersRepository>()));

  // Cubits
  sl.registerFactory(() => OrdersCubit(sl<GetMyOrders>()));
  sl.registerFactory(() => OrderDetailsCubit(sl<GetOrderDetails>()));

  // ===============================
  // Profile Feature
  // ===============================

  // Repositories
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl<ApiService>()),
  );

  // ===============================
  // Shared Services
  // ===============================

  // Auth interceptor
  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(sl<SecureStorageService>()),
  );

  // Add auth interceptor to Dio
  sl<Dio>().interceptors.add(sl<AuthInterceptor>());
}
