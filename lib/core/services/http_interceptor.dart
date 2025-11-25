import 'package:dio/dio.dart';
import 'token_manager.dart';

/// HTTP interceptor with automatic token refresh capabilities
/// Handles token injection, refresh suggestions, and automatic refresh responses
class AutoRefreshInterceptor extends Interceptor {
  final TokenManager _tokenManager;

  AutoRefreshInterceptor({TokenManager? tokenManager})
    : _tokenManager = tokenManager ?? TokenManager.instance;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Add authorization headers if available
      final authHeaders = await _tokenManager.getAuthHeaders();
      options.headers.addAll(authHeaders);

      handler.next(options);
    } catch (e) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: 'Failed to add auth headers: $e',
        ),
      );
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    try {
      // Extract headers as Map<String, String>
      final headers = <String, String>{};
      response.headers.forEach((key, values) {
        if (values.isNotEmpty) {
          headers[key.toLowerCase()] = values.first;
        }
      });

      // Check for refresh suggestions from backend
      _tokenManager.handleRefreshSuggestion(headers);

      // Check for automatic token refresh by backend
      if (response.data is Map<String, dynamic>) {
        await _tokenManager.handleAutomaticRefresh(
          headers,
          response.data as Map<String, dynamic>,
        );
      }

      handler.next(response);
    } catch (e) {
      // Log error but don't fail the response
      print('[HTTP_INTERCEPTOR] Error processing response: $e');
      handler.next(response);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    // Handle 401 errors with automatic token refresh
    if (err.response?.statusCode == 401) {
      try {
        // Attempt to refresh token
        final refreshSuccess = await _tokenManager.refreshAccessToken();

        if (refreshSuccess) {
          // Retry the original request with new token
          final authHeaders = await _tokenManager.getAuthHeaders();
          requestOptions.headers.addAll(authHeaders);

          final dio = Dio();
          final retryResponse = await dio.fetch(requestOptions);
          handler.resolve(retryResponse);
          return;
        }
      } catch (e) {
        // If refresh fails, clear tokens and let the error propagate
        await _tokenManager.clearTokens();
        print('[HTTP_INTERCEPTOR] Token refresh failed: $e');
      }
    }

    handler.next(err);
  }
}

/// Logging interceptor for development
class TokenAwareLogInterceptor extends Interceptor {
  final bool logRequest;
  final bool logResponse;
  final bool logError;

  TokenAwareLogInterceptor({
    this.logRequest = true,
    this.logResponse = true,
    this.logError = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (logRequest) {
      print('🚀 [REQUEST] ${options.method} ${options.uri}');

      // Log headers (mask sensitive data)
      final maskedHeaders = <String, dynamic>{};
      options.headers.forEach((key, value) {
        if (key.toLowerCase().contains('authorization') ||
            key.toLowerCase().contains('token')) {
          maskedHeaders[key] = '***MASKED***';
        } else {
          maskedHeaders[key] = value;
        }
      });
      print('📝 Headers: $maskedHeaders');

      if (options.data != null) {
        print('📦 Data: ${options.data}');
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (logResponse) {
      print(
        '✅ [RESPONSE] ${response.statusCode} ${response.requestOptions.uri}',
      );

      // Check for token-related headers
      final tokenHeaders = <String, String>{};
      response.headers.forEach((key, values) {
        final lowerKey = key.toLowerCase();
        if (lowerKey.contains('token') ||
            lowerKey.contains('refresh') ||
            lowerKey.contains('expires')) {
          if (values.isNotEmpty) {
            tokenHeaders[key] = values.first;
          }
        }
      });

      if (tokenHeaders.isNotEmpty) {
        print('🔑 Token Headers: $tokenHeaders');
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (logError) {
      print('❌ [ERROR] ${err.response?.statusCode} ${err.requestOptions.uri}');
      print('💥 Message: ${err.message}');

      if (err.response?.statusCode == 401) {
        print('🔐 Authentication error detected');
      }
    }

    handler.next(err);
  }
}
