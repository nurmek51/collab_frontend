import 'dart:async';
import 'dart:math';
import 'package:dio/dio.dart';
import '../../../shared/state/auth.dart';
import '../config/app_config.dart';

/// Enhanced token manager with automatic refresh capabilities
/// Following the guide's specifications for seamless authentication
class TokenManager {
  // Buffer time before token expiration to refresh proactively (5 minutes)
  static const int _proactiveRefreshThresholdSeconds = 300;

  // Maximum retry attempts for failed requests
  static const int _maxRetryAttempts = 3;

  // Delay between retry attempts (1 second)
  static const Duration _retryDelay = Duration(seconds: 1);

  static TokenManager? _instance;
  static TokenManager get instance => _instance ??= TokenManager._();

  TokenManager._();

  // State management
  bool _isRefreshing = false;
  final List<Completer<String?>> _failedQueue = [];

  // Use AuthStore for token storage
  final AuthStore _authStore = AuthStore();
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Save authentication data after successful authentication
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
    required int expiresIn,
    required String userId,
    String? currentRole,
  }) async {
    try {
      // Use AuthStore for token storage
      await _authStore.setTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        tokenType: 'Bearer',
        expiresIn: expiresIn,
        userId: userId,
        role: currentRole,
      );

      // Calculate expiration timestamp for logging
      final expirationTimestamp =
          DateTime.now().millisecondsSinceEpoch + (expiresIn * 1000);

      _logTokenEvent('tokens_stored', {
        'expires_at': DateTime.fromMillisecondsSinceEpoch(
          expirationTimestamp,
        ).toIso8601String(),
        'user_id': userId,
        'role': currentRole,
      });
    } catch (e) {
      print('Error saving tokens: $e');
    }
  }

  /// Get stored access token
  Future<String?> get accessToken async {
    try {
      return await _authStore.getAccessToken();
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  /// Get stored refresh token
  Future<String?> get refreshToken async {
    try {
      return await _authStore.getRefreshToken();
    } catch (e) {
      print('Error getting refresh token: $e');
      return null;
    }
  }

  /// Get token expiration time in seconds
  Future<int?> get expiresIn async {
    try {
      final authState = await _authStore.getAuthState();
      return authState.expiresIn;
    } catch (e) {
      print('Error getting expires in: $e');
      return null;
    }
  }

  /// Get stored user ID
  Future<String?> get userId async {
    try {
      return await _authStore.getUserId();
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  /// Get current user role
  Future<String?> get currentRole async {
    try {
      return await _authStore.getRole();
    } catch (e) {
      print('Error getting current role: $e');
      return null;
    }
  }

  /// Get token expiration timestamp
  Future<int?> get tokenExpirationTimestamp async {
    try {
      final authState = await _authStore.getAuthState();
      if (authState.tokenCreatedAt != null && authState.expiresIn != null) {
        return authState.tokenCreatedAt!
            .add(Duration(seconds: authState.expiresIn!))
            .millisecondsSinceEpoch;
      }
      return null;
    } catch (e) {
      print('Error getting token expiration: $e');
      return null;
    }
  }

  /// Check if token is expired
  Future<bool> isTokenExpired() async {
    try {
      final expirationTimestamp = await tokenExpirationTimestamp;
      if (expirationTimestamp == null) return true;

      final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
      return currentTimestamp >= expirationTimestamp;
    } catch (e) {
      print('Error checking token expiration: $e');
      return true;
    }
  }

  /// Check if token is expiring soon (within threshold)
  Future<bool> isTokenExpiringSoon() async {
    final expirationTimestamp = await tokenExpirationTimestamp;
    if (expirationTimestamp == null) return true;

    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    final thresholdTimestamp =
        currentTimestamp + (_proactiveRefreshThresholdSeconds * 1000);

    return thresholdTimestamp >= expirationTimestamp;
  }

  /// Get remaining time until token expiry in seconds
  Future<int?> getTokenExpiresInSeconds() async {
    final expirationTimestamp = await tokenExpirationTimestamp;
    if (expirationTimestamp == null) return null;

    final currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    final remainingMs = expirationTimestamp - currentTimestamp;

    return remainingMs > 0 ? (remainingMs / 1000).round() : 0;
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await accessToken;
    if (token == null || token.isEmpty) return false;

    return !(await isTokenExpired());
  }

  /// Clear all authentication data (logout)
  Future<void> clearTokens() async {
    try {
      await _authStore.clearTokens();
      _logTokenEvent('tokens_cleared');
    } catch (e) {
      print('Error clearing tokens: $e');
    }
  }

  /// Process queued requests after token refresh
  void _processQueue(Exception? error, String? token) {
    final queue = List<Completer<String?>>.from(_failedQueue);
    _failedQueue.clear();

    for (final completer in queue) {
      if (error != null) {
        completer.completeError(error);
      } else {
        completer.complete(token);
      }
    }
  }

  /// Refresh access token using refresh token
  Future<bool> refreshAccessToken() async {
    if (_isRefreshing) {
      // If already refreshing, wait for the ongoing refresh
      final completer = Completer<String?>();
      _failedQueue.add(completer);

      try {
        await completer.future;
        return true;
      } catch (e) {
        return false;
      }
    }

    _isRefreshing = true;
    _logTokenEvent('token_refresh_started');

    try {
      final currentRefreshToken = await refreshToken;
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        _logTokenEvent('token_refresh_failed', {'reason': 'no_refresh_token'});
        _processQueue(Exception('No refresh token available'), null);
        return false;
      }

      final response = await _dio.post(
        '/auth/refresh',
        data: {'refresh_token': currentRefreshToken},
        options: Options(headers: {'Authorization': null}),
      );

      if (response.data is! Map<String, dynamic>) {
        _processQueue(Exception('Invalid refresh response format'), null);
        return false;
      }

      final payload = response.data as Map<String, dynamic>;
      if (payload['success'] != true ||
          payload['data'] is! Map<String, dynamic>) {
        _processQueue(Exception('Refresh token request failed'), null);
        return false;
      }

      final tokenData = payload['data'] as Map<String, dynamic>;
      final newAccessToken = tokenData['access_token'] as String?;
      final newRefreshToken = tokenData['refresh_token'] as String?;

      if (newAccessToken == null || newRefreshToken == null) {
        _processQueue(Exception('Refresh response missing token pair'), null);
        return false;
      }

      final authState = await _authStore.getAuthState();
      await _authStore.setTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
        tokenType:
            tokenData['token_type'] as String? ??
            authState.tokenType ??
            'Bearer',
        expiresIn:
            tokenData['expires_in'] as int? ?? authState.expiresIn ?? 86400,
        refreshExpiresIn:
            tokenData['refresh_expires_in'] as int? ??
            authState.refreshExpiresIn,
        userId: authState.userId,
        role: authState.role,
      );

      _logTokenEvent('token_refresh_success');
      _processQueue(null, newAccessToken);
      return true;
    } catch (e) {
      _logTokenEvent('token_refresh_failed', {
        'reason': 'error',
        'error': e.toString(),
      });
      _processQueue(Exception('Token refresh error: $e'), null);
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  /// Proactively refresh token (called before expiry)
  Future<void> refreshTokenProactively() async {
    if (_isRefreshing) return;

    _logTokenEvent('proactive_refresh_started');

    final success = await refreshAccessToken();
    if (success) {
      _logTokenEvent('proactive_refresh_success');
    } else {
      _logTokenEvent('proactive_refresh_failed');
    }
  }

  /// Make an authenticated request with automatic token refresh and retry logic
  Future<T> makeAuthenticatedRequest<T>(
    Future<T> Function() request, {
    int retryCount = 0,
  }) async {
    // Check if token needs refresh before making request
    if (await isTokenExpired()) {
      final refreshSuccess = await refreshAccessToken();
      if (!refreshSuccess) {
        throw Exception('Authentication failed. Please log in again.');
      }
    }

    try {
      return await request();
    } on DioException catch (e) {
      // Handle 401 errors with token refresh and retry
      if (e.response?.statusCode == 401 && retryCount < _maxRetryAttempts) {
        _logTokenEvent('request_401_retry', {'retry_count': retryCount});

        final refreshSuccess = await refreshAccessToken();
        if (!refreshSuccess) {
          throw Exception('Authentication failed. Please log in again.');
        }

        // Retry the request with exponential backoff
        await Future.delayed(_retryDelay * pow(2, retryCount).toInt());
        return makeAuthenticatedRequest(request, retryCount: retryCount + 1);
      }

      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  /// Get authorization headers for API requests
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await accessToken;
    final refreshTokenValue = await refreshToken;

    final headers = <String, String>{};

    // Add authorization header if token exists
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    // Add refresh token header for automatic refresh by backend middleware
    if (refreshTokenValue != null && refreshTokenValue.isNotEmpty) {
      headers['X-Refresh-Token'] = refreshTokenValue;
    }

    return headers;
  }

  /// Handle refresh suggestion from backend
  void handleRefreshSuggestion(Map<String, String> responseHeaders) {
    final suggestedHeader = responseHeaders['x-token-refresh-suggested'];
    final expiresInHeader = responseHeaders['x-token-expires-in'];

    if (suggestedHeader == 'true') {
      _logTokenEvent('backend_refresh_suggested', {
        'expires_in': expiresInHeader,
      });

      // Proactively refresh if expiring soon and not already refreshing
      if (expiresInHeader != null) {
        final expiresInSeconds = int.tryParse(expiresInHeader);
        if (expiresInSeconds != null &&
            expiresInSeconds < _proactiveRefreshThresholdSeconds &&
            !_isRefreshing) {
          refreshTokenProactively();
        }
      }
    }
  }

  /// Handle automatic token refresh by backend
  Future<void> handleAutomaticRefresh(
    Map<String, String> responseHeaders,
    Map<String, dynamic>? responseData,
  ) async {
    final refreshedHeader = responseHeaders['x-token-refreshed'];

    if (refreshedHeader == 'true' && responseData != null) {
      _logTokenEvent('backend_automatic_refresh');

      final tokenRefreshed = responseData['token_refreshed'] as bool?;
      final authData = responseData['auth_data'] as Map<String, dynamic>?;

      if (tokenRefreshed == true && authData != null) {
        await setTokens(
          accessToken: authData['access_token'] as String,
          refreshToken: authData['refresh_token'] as String,
          expiresIn: authData['expires_in'] as int,
          userId: authData['user_id'] as String? ?? await userId ?? '',
          currentRole: authData['current_role'] as String? ?? await currentRole,
        );

        _logTokenEvent('backend_tokens_updated');
      }
    }
  }

  /// Get token health status for debugging
  Future<Map<String, dynamic>> getTokenHealthStatus() async {
    final expiresInSeconds = await getTokenExpiresInSeconds();

    return {
      'has_access_token': await accessToken != null,
      'has_refresh_token': await refreshToken != null,
      'is_expired': await isTokenExpired(),
      'is_expiring_soon': await isTokenExpiringSoon(),
      'expires_in_seconds': expiresInSeconds,
      'expires_at': await tokenExpirationTimestamp != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (await tokenExpirationTimestamp)!,
            ).toIso8601String()
          : null,
      'is_refreshing': _isRefreshing,
      'queued_requests': _failedQueue.length,
    };
  }

  /// Log token events for debugging and monitoring
  void _logTokenEvent(String event, [Map<String, dynamic>? data]) {
    final timestamp = DateTime.now().toIso8601String();
    print('[TOKEN] $timestamp - $event: ${data ?? {}}');

    // In production, you might want to send this to an analytics service
    // analytics.track('token_event', {'event': event, ...?data});
  }
}
