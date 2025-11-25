import 'package:dio/dio.dart';
import 'token_manager.dart';
import 'http_interceptor.dart';
import 'background_refresh_manager.dart';
import '../config/app_config.dart';

class ApiService {
  static String get baseUrl => AppConfig.baseUrl;

  static ApiService? _instance;
  static ApiService get instance => _instance ??= ApiService._();

  late final Dio _dio;
  final TokenManager _tokenManager = TokenManager.instance;
  final BackgroundRefreshManager _backgroundRefresh =
      BackgroundRefreshManager.instance;

  ApiService._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(AutoRefreshInterceptor(tokenManager: _tokenManager));

    _dio.interceptors.add(
      TokenAwareLogInterceptor(
        logRequest: true,
        logResponse: false,
        logError: true,
      ),
    );
  }

  Future<Map<String, dynamic>> sendOtp(
    String phoneNumber, {
    String? role,
  }) async {
    try {
      final data = {'phone': phoneNumber};
      if (role != null) {
        data['role'] = role;
      }

      final response = await _dio.post('/auth/request-otp', data: data);

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {'phone': phoneNumber, 'otp': otp},
      );

      final data = response.data as Map<String, dynamic>;

      // Check if the response has the expected structure
      if (data['success'] == true && data['data'] != null) {
        final tokenData = data['data'] as Map<String, dynamic>;

        if (tokenData.containsKey('access_token')) {
          await _tokenManager.setTokens(
            accessToken: tokenData['access_token'] as String,
            refreshToken: '', // No refresh token from API
            expiresIn: tokenData['expires_in'] as int? ?? 86400,
            userId: '', // Will be extracted from JWT if needed
            currentRole: null,
          );

          _backgroundRefresh.startOnLogin();
        }
      }

      return data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> switchRole(String role) async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      final response = await _dio.post(
        '/auth/switch-role',
        data: {'role': role},
      );

      return response.data as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> createFreelancerProfile({
    required String name,
    required String surname,
    required String iin,
    required String city,
    required List<Map<String, String>> specializationsWithLevels,
    String? email,
    Map<String, String>? socialLinks,
    List<String>? portfolioLinks,
  }) async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      final data = {
        'name': name,
        'surname': surname,
        'iin': iin,
        'city': city,
        'specializations_with_levels': specializationsWithLevels,
      };

      if (email != null) data['email'] = email;
      if (socialLinks != null) data['social_links'] = socialLinks;
      if (portfolioLinks != null) data['portfolio_links'] = portfolioLinks;

      final response = await _dio.post(
        '/profiles/freelancer/onboarding',
        data: data,
      );

      return response.data as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      final response = await _dio.get('/users/me');
      return response.data as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      final response = await _dio.get('/users/me');
      // Safely handle the response data
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      } else {
        // Return empty map if data is not in expected format
        return <String, dynamic>{};
      }
    });
  }

  Future<List<dynamic>> getMyOrders({int limit = 20, int offset = 0}) async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      final response = await _dio.get(
        '/orders/my',
        queryParameters: {'limit': limit, 'offset': offset},
      );

      // Debug logging
      print('🔍 [getMyOrders] Response status: ${response.statusCode}');
      print('🔍 [getMyOrders] Response data: ${response.data}');

      // Handle the wrapped response format
      if (response.data is Map<String, dynamic>) {
        final responseData = response.data as Map<String, dynamic>;

        if (responseData['success'] == true) {
          final data = responseData['data'];
          if (data is List) {
            print('✅ [getMyOrders] Successfully parsed ${data.length} orders');
            return data;
          } else {
            print('⚠️ [getMyOrders] Data is not a list: $data');
            return [];
          }
        } else {
          print(
            '❌ [getMyOrders] API returned success=false: ${responseData['error']}',
          );
          return [];
        }
      } else {
        print('❌ [getMyOrders] Response is not a Map: ${response.data}');
        return [];
      }
    });
  }

  Future<List<dynamic>> getOrdersFeed({int limit = 20, int offset = 0}) async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      final response = await _dio.get(
        '/orders/feed',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return response.data as List<dynamic>;
    });
  }

  Future<Map<String, dynamic>> get(String path) async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      final response = await _dio.get(path);
      return response.data as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> data,
  ) async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> createOrder({
    required String companyName,
    required String companyPosition,
    required String orderDescription,
    String? firstName,
    String? lastName,
    String? title,
    List<String>? specializations,
    Map<String, dynamic>? orderCondition,
    String? requirements,
    String? chatLink,
  }) async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      final data = <String, dynamic>{
        'company_name': companyName,
        'company_position': companyPosition,
        'order_description': orderDescription,
      };

      // Add optional name fields if provided
      if (firstName != null && firstName.isNotEmpty) {
        data['name'] = firstName;
      }
      if (lastName != null && lastName.isNotEmpty) {
        data['surname'] = lastName;
      }
      if (title != null && title.isNotEmpty) {
        data['order_title'] = title;
      }

      // Add optional fields if provided
      if (specializations != null && specializations.isNotEmpty) {
        data['order_specializations'] = specializations;
      }
      if (orderCondition != null) {
        data['order_condition'] = orderCondition;
      }
      if (requirements != null && requirements.isNotEmpty) {
        data['requirements'] = requirements;
      }
      if (chatLink != null && chatLink.isNotEmpty) {
        data['chat_link'] = chatLink;
      }

      final response = await _dio.post('/orders/create', data: data);

      return response.data as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      final response = await _dio.get('/orders/offers/$orderId');
      return response.data as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> respondToOrder({
    required String orderId,
    String? message,
    String? portfolioLinks,
  }) async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      final data = <String, dynamic>{};
      if (message != null) data['message'] = message;
      if (portfolioLinks != null) data['portfolio_links'] = portfolioLinks;

      final response = await _dio.post(
        '/orders/offers/$orderId/respond',
        data: data,
      );
      return response.data as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> getMyWork() async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      final response = await _dio.get('/freelancer/my-work');
      return response.data as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> getProjectDetails(String projectId) async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      final response = await _dio.get('/freelancer/projects/$projectId');
      return response.data as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> getClientProfile(String userId) async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      final response = await _dio.get('/profiles/client/$userId');
      return response.data as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> updateClientProfile({
    required String name,
    required String surname,
    required String phoneNumber,
  }) async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      final data = {
        'name': name,
        'surname': surname,
        'phone_number': phoneNumber,
      };

      final response = await _dio.put('/clients/profile', data: data);

      return response.data as Map<String, dynamic>;
    });
  }

  Future<void> logout() async {
    try {
      _backgroundRefresh.stopOnLogout();

      await _tokenManager.clearTokens();
    } catch (e) {
      await _tokenManager.clearTokens();
    }
  }

  Future<bool> isAuthenticated() async {
    return await _tokenManager.isAuthenticated();
  }

  Future<String?> getCurrentUserId() async {
    return await _tokenManager.userId;
  }

  Future<String?> getCurrentUserRole() async {
    return await _tokenManager.currentRole;
  }

  Future<Map<String, dynamic>> getTokenHealth() async {
    return await _tokenManager.getTokenHealthStatus();
  }

  Future<bool> refreshToken() async {
    return await _tokenManager.refreshAccessToken();
  }

  Future<Map<String, dynamic>> getAdminNotifications({
    int limit = 50,
    int offset = 0,
  }) async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      final response = await _dio.get(
        '/simplified/admin/notifications',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return response.data as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> markNotificationsAsRead(
    List<String> notificationIds,
  ) async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      final response = await _dio.post(
        '/simplified/admin/notifications/mark-read',
        data: {'notification_ids': notificationIds},
      );
      return response.data as Map<String, dynamic>;
    });
  }

  Future<Map<String, dynamic>> requestHelp() async {
    return await _tokenManager.makeAuthenticatedRequest(() async {
      // Get user information from the authenticated endpoint instead of relying on stored userId
      final currentUserResponse = await getCurrentUser();
      final userData = currentUserResponse['data'] as Map<String, dynamic>?;
      print('🔍 [requestHelp] Current user data: $userData');
      final userId =
          userData?['id'] as String? ?? userData?['user_id'] as String?;

      if (userId == null || userId.isEmpty) {
        throw Exception(
          'Unable to identify user. Please try logging in again.',
        );
      }

      // Try to get client_id from user profile, but handle it gracefully
      String? clientId;
      try {
        final userProfile = await getUserProfile();
        final data = userProfile['data'];
        if (data is Map<String, dynamic>) {
          clientId = data['client_id'] as String?;
        }
      } catch (e) {
        // If we can't get client_id, continue with null
        print('Warning: Could not fetch client_id: $e');
      }

      final requestData = {
        'user_id': userId,
        if (clientId != null) 'client_id': clientId,
      };

      final response = await _dio.post('/request-help', data: requestData);
      return response.data as Map<String, dynamic>;
    });
  }

  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode == 400) {
          return 'Invalid phone number format.';
        } else if (statusCode == 429) {
          return 'Too many requests. Please try again later.';
        } else if (statusCode != null && statusCode >= 500) {
          return 'Server error. Please try again later.';
        }
        return 'Request failed with status: $statusCode';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}
