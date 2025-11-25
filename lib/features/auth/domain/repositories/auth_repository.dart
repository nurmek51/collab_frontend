import '../entities/auth_response.dart';
import '../entities/user.dart';

/// Abstract repository for authentication operations
/// Defines the contract for authentication data operations
abstract class AuthRepository {
  /// Send OTP to the given phone number with optional role
  Future<void> sendOtp(String phoneNumber, {String? role});

  /// Verify OTP and return authentication response
  Future<AuthResponse> verifyOtp(String phoneNumber, String otp);

  /// Switch user role after authentication
  Future<void> switchRole(String role);

  /// Refresh authentication token
  Future<bool> refreshToken();

  /// Logout user and clear authentication data
  Future<void> logout();

  /// Check if user is currently authenticated
  Future<bool> isAuthenticated();

  /// Get current user ID
  Future<String?> getCurrentUserId();

  /// Get current user role
  Future<String?> getCurrentUserRole();

  /// Get current user information
  Future<User> getCurrentUser();
}
