import 'dart:async';

import 'package:dio/dio.dart';
import '../state/auth.dart';
import '../../core/config/app_config.dart';

/// API response envelope structure
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  const ApiResponse({required this.success, this.data, this.error});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      error: json['error'],
    );
  }
}

/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({required this.message, this.statusCode, this.data});

  @override
  String toString() => 'ApiException: $message';
}

/// Base API client for making HTTP requests
class ApiClient {
  static String get baseUrl => AppConfig.baseUrl;

  final Dio _dio;
  final AuthStore _authStore;
  Future<bool>? _pendingRefresh;

  ApiClient(this._authStore, {Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'Content-Type': 'application/json'},
            ),
          ) {
    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra['skipAuth'] == true) {
            handler.next(options);
            return;
          }

          final token = await _authStore.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final shouldHandleRefresh =
              error.response?.statusCode == 401 &&
              error.requestOptions.extra['retryAfterRefresh'] != true &&
              error.requestOptions.extra['skipAuthRefresh'] != true;

          if (shouldHandleRefresh) {
            final refreshed = await _refreshSession();
            if (refreshed) {
              final accessToken = await _authStore.getAccessToken();
              if (accessToken != null && accessToken.isNotEmpty) {
                final retryOptions = error.requestOptions;
                retryOptions.headers['Authorization'] = 'Bearer $accessToken';
                retryOptions.extra['retryAfterRefresh'] = true;

                try {
                  final retryResponse = await _dio.fetch(retryOptions);
                  handler.resolve(retryResponse);
                  return;
                } catch (_) {
                  await _authStore.clearTokens();
                }
              }
            } else {
              await _authStore.clearTokens();
            }
          }

          handler.next(error);
        },
      ),
    );

    // Add logging interceptor for development
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[API] $obj'),
      ),
    );
  }

  /// Generic GET request with envelope parsing
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic POST request with envelope parsing
  Future<T> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic PUT request with envelope parsing
  Future<T> put<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic DELETE request with envelope parsing
  Future<T> delete<T>(String path, {T Function(dynamic)? fromJson}) async {
    try {
      final response = await _dio.delete(path);
      return _handleResponse<T>(response, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle response and parse envelope
  T _handleResponse<T>(Response response, T Function(dynamic)? fromJson) {
    final apiResponse = ApiResponse<T>.fromJson(
      response.data as Map<String, dynamic>,
      fromJson,
    );

    if (!apiResponse.success) {
      throw ApiException(
        message: apiResponse.error ?? 'Unknown error occurred',
        statusCode: response.statusCode,
        data: apiResponse.data,
      );
    }

    return apiResponse.data as T;
  }

  /// Handle Dio errors and convert to ApiException
  ApiException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const ApiException(
          message: 'Connection timeout. Please check your internet connection.',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        String message = 'Request failed';

        // Try to parse error from response envelope
        if (error.response?.data is Map<String, dynamic>) {
          final responseData = error.response!.data as Map<String, dynamic>;
          message = responseData['error'] ?? message;
        }

        if (statusCode == 400) {
          message = 'Invalid request data';
        } else if (statusCode == 401) {
          message = 'Unauthorized access';
        } else if (statusCode == 403) {
          message = 'Access forbidden';
        } else if (statusCode == 404) {
          message = 'Resource not found';
        } else if (statusCode == 422) {
          message = 'Validation error';
        } else if (statusCode != null && statusCode >= 500) {
          message = 'Server error. Please try again later.';
        }

        return ApiException(
          message: message,
          statusCode: statusCode,
          data: error.response?.data,
        );
      case DioExceptionType.connectionError:
        return const ApiException(
          message: 'No internet connection. Please check your network.',
        );
      case DioExceptionType.cancel:
        return const ApiException(message: 'Request was cancelled.');
      default:
        return const ApiException(
          message: 'An unexpected error occurred. Please try again.',
        );
    }
  }

  Future<bool> _refreshSession() async {
    if (_pendingRefresh != null) {
      return _pendingRefresh!;
    }

    final completer = Completer<bool>();
    _pendingRefresh = completer.future;

    try {
      final refreshToken = await _authStore.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        completer.complete(false);
        return false;
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          extra: {'skipAuth': true, 'skipAuthRefresh': true},
          headers: {'Authorization': null},
        ),
      );

      final body = response.data as Map<String, dynamic>;
      final success = body['success'] == true;
      final data = body['data'] as Map<String, dynamic>?;

      if (!success || data == null) {
        completer.complete(false);
        return false;
      }

      final newAccessToken = data['access_token'] as String?;
      final newRefreshToken = data['refresh_token'] as String?;

      if (newAccessToken == null || newRefreshToken == null) {
        completer.complete(false);
        return false;
      }

      final previousState = await _authStore.getAuthState();

      await _authStore.setTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        tokenType: data['token_type'] as String? ?? 'bearer',
        expiresIn: data['expires_in'] as int? ?? 86400,
        refreshExpiresIn: data['refresh_expires_in'] as int?,
        role: previousState.role,
        userId: previousState.userId,
      );

      completer.complete(true);
      return true;
    } catch (_) {
      completer.complete(false);
      return false;
    } finally {
      _pendingRefresh = null;
    }
  }
}
