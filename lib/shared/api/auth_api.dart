import 'package:dio/dio.dart';

import '../utils/avatar_file_utils.dart';
import 'avatar_models.dart';
import 'client.dart';
import '../state/auth.dart';
import '../services/admin_session.dart';
import '../../core/navigation/app_router.dart';

/// Authentication API endpoints
class AuthApi {
  final ApiClient _client;
  final AuthStore _authStore;
  final AdminSession? _adminSession;

  AuthApi(this._client, this._authStore, {AdminSession? adminSession})
    : _adminSession = adminSession;

  void _notifyAuthChanged() {
    AppRouter.authRefreshNotifier.refresh();
  }

  /// Request OTP for phone number
  Future<Map<String, dynamic>> requestOtp(String phoneNumber) async {
    return await _client.post<Map<String, dynamic>>(
      '/auth/request-otp',
      data: {'phone_number': phoneNumber},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Verify OTP and get tokens
  Future<Map<String, dynamic>> verifyOtp({
    required String phoneNumber,
    required String code,
    String? firebaseToken,
  }) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/verify-otp',
      data: {
        'phone_number': phoneNumber,
        'code': code,
        if (firebaseToken != null) 'firebase_token': firebaseToken,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );

    // Save tokens after successful verification
    if (response['access_token'] != null) {
      await _authStore.setTokens(
        accessToken: response['access_token'] as String,
        refreshToken: response['refresh_token'] as String,
        tokenType: response['token_type'] as String? ?? 'bearer',
        expiresIn: response['expires_in'] as int? ?? 86400,
        refreshExpiresIn: response['refresh_expires_in'] as int?,
      );
      _notifyAuthChanged();
    }

    return response;
  }

  /// Refresh access and refresh tokens
  Future<Map<String, dynamic>> refreshToken() async {
    final refreshToken = await _authStore.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw Exception('No refresh token available');
    }

    final response = await _client.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
      fromJson: (data) => data as Map<String, dynamic>,
    );

    if (response['access_token'] != null && response['refresh_token'] != null) {
      await _authStore.setTokens(
        accessToken: response['access_token'] as String,
        refreshToken: response['refresh_token'] as String,
        tokenType: response['token_type'] as String? ?? 'bearer',
        expiresIn: response['expires_in'] as int? ?? 86400,
        refreshExpiresIn: response['refresh_expires_in'] as int?,
      );
      _notifyAuthChanged();
    }

    return response;
  }

  /// Select role for authenticated user
  Future<Map<String, dynamic>> selectRole(String role) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/auth/select-role',
      data: {'role': role},
      fromJson: (data) => data as Map<String, dynamic>,
    );

    // Save role after successful selection
    await _authStore.setRole(role);
    _notifyAuthChanged();

    return response;
  }

  /// Get current user information
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await _client.get<Map<String, dynamic>>(
      '/users/me',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> extractUserData(Map<String, dynamic> user) {
    final nestedData = user['data'];
    if (nestedData is Map<String, dynamic>) {
      return nestedData;
    }

    return user;
  }

  bool userHasRole(Map<String, dynamic> user, String role) {
    final normalizedUser = extractUserData(user);
    final expectedRole = role.trim().toLowerCase();

    final roles = normalizedUser['roles'];
    if (roles is Iterable) {
      return roles.any(
        (item) => item.toString().trim().toLowerCase() == expectedRole,
      );
    }

    final currentRole = normalizedUser['role'];
    if (currentRole is String) {
      return currentRole.trim().toLowerCase() == expectedRole;
    }

    return false;
  }

  Future<bool> isCurrentUserAdmin() async {
    try {
      final user = await getCurrentUser();
      return userHasRole(user, 'admin');
    } catch (_) {
      return false;
    }
  }

  /// Update current user information
  Future<Map<String, dynamic>> updateUser({
    String? name,
    String? surname,
    String? phoneNumber,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (surname != null) data['surname'] = surname;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;

    return await _client.put<Map<String, dynamic>>(
      '/users/me',
      data: data,
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  Future<AvatarUploadResult> uploadAvatar({
    required String fileName,
    required List<int> fileBytes,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        fileBytes,
        filename: fileName,
        contentType: mimeTypeForAvatarFile(fileName),
      ),
    });

    return _client.postMultipart<AvatarUploadResult>(
      '/users/me/avatar',
      data: formData,
      onSendProgress: onSendProgress,
      fromJson: (data) =>
          AvatarUploadResult.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AvatarDownloadResult> getMyAvatarDownloadUrl() async {
    return _client.get<AvatarDownloadResult>(
      '/users/me/avatar',
      fromJson: (data) =>
          AvatarDownloadResult.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AvatarDownloadResult> getUserAvatarDownloadUrl(String userId) async {
    return _client.get<AvatarDownloadResult>(
      '/users/$userId/avatar',
      fromJson: (data) =>
          AvatarDownloadResult.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<AvatarDeleteResult> deleteAvatar() async {
    return _client.delete<AvatarDeleteResult>(
      '/users/me/avatar',
      fromJson: (data) =>
          AvatarDeleteResult.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Logout (clear local tokens)
  Future<void> logout() async {
    _adminSession?.clear();
    await _authStore.clearTokens();
    _notifyAuthChanged();
  }
}
