import '../../../../shared/network/dio_client.dart';

/// Abstract remote data source for authentication
abstract class AuthRemoteDataSource {
  /// Send OTP to phone number
  Future<void> sendOtp(String phoneNumber, {String? role});

  /// Verify OTP and get authentication data
  Future<Map<String, dynamic>> verifyOtp(
    String phoneNumber,
    String code, {
    String? firebaseToken,
  });

  /// Switch user role
  Future<void> switchRole(String role);

  /// Refresh authentication token
  Future<Map<String, dynamic>> refreshToken(String refreshToken);

  /// Logout user
  Future<void> logout();

  /// Get current user information
  Future<Map<String, dynamic>> getCurrentUser();
}

/// Implementation of auth remote data source
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<void> sendOtp(String phoneNumber, {String? role}) async {
    final data = {'phone_number': phoneNumber, if (role != null) 'role': role};

    await _dioClient.post('/auth/request-otp', data: data);
  }

  @override
  Future<Map<String, dynamic>> verifyOtp(
    String phoneNumber,
    String code, {
    String? firebaseToken,
  }) async {
    final data = {
      'phone_number': phoneNumber,
      'code': code,
      if (firebaseToken != null) 'firebase_token': firebaseToken,
    };

    final response = await _dioClient.post('/auth/verify-otp', data: data);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> switchRole(String role) async {
    final data = {'role': role};
    await _dioClient.post('/auth/select-role', data: data);
  }

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final data = {'refresh_token': refreshToken};

    final response = await _dioClient.post('/auth/refresh', data: data);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> logout() async {
    await _dioClient.post('/auth/logout');
  }

  @override
  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _dioClient.get('/auth/me');
    return response.data as Map<String, dynamic>;
  }
}
