import 'package:dio/dio.dart';
import '../../../../shared/storage/secure_storage_service.dart';

/// Auth interceptor for automatic token attachment and refresh
class AuthInterceptor extends Interceptor {
  final SecureStorageService _secureStorage;

  AuthInterceptor(this._secureStorage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Add auth header if available
    final authHeader = await _secureStorage.getAuthorizationHeader();
    if (authHeader != null) {
      options.headers['Authorization'] = authHeader;
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 errors by clearing tokens (token refresh will be handled by repository)
    if (err.response?.statusCode == 401) {
      await _secureStorage.clearAll();
    }

    handler.next(err);
  }
}
