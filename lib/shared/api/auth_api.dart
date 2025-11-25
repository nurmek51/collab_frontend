import 'client.dart';
import '../state/auth.dart';

/// Authentication API endpoints
class AuthApi {
  final ApiClient _client;
  final AuthStore _authStore;

  AuthApi(this._client, this._authStore);

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
        tokenType: response['token_type'] as String? ?? 'bearer',
        expiresIn: response['expires_in'] as int? ?? 86400,
      );
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

    return response;
  }

  /// Get current user information
  Future<Map<String, dynamic>> getCurrentUser() async {
    return await _client.get<Map<String, dynamic>>(
      '/users/me',
      fromJson: (data) => data as Map<String, dynamic>,
    );
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

  /// Logout (clear local tokens)
  Future<void> logout() async {
    await _authStore.clearTokens();
  }
}
