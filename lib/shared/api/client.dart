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

  late final Dio _dio;
  final AuthStore _authStore;

  ApiClient(this._authStore) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _authStore.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 errors by clearing tokens
          if (error.response?.statusCode == 401) {
            await _authStore.clearTokens();
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
}
