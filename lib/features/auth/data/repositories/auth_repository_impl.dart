import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/auth_response.dart';
import '../../domain/entities/user.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../../../shared/storage/secure_storage_service.dart';

/// Implementation of authentication repository
/// Handles all authentication-related API calls and data transformation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required SecureStorageService secureStorage,
  }) : _remoteDataSource = remoteDataSource,
       _secureStorage = secureStorage;

  @override
  Future<void> sendOtp(String phoneNumber, {String? role}) async {
    try {
      await _remoteDataSource.sendOtp(phoneNumber, role: role);
    } catch (e) {
      throw Exception('Failed to send OTP: $e');
    }
  }

  @override
  Future<AuthResponse> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _remoteDataSource.verifyOtp(phoneNumber, otp);
      final authModel = AuthResponseModel.fromJson(response);
      final existingUserId = await _secureStorage.getUserId();

      // Save tokens to secure storage
      await _saveAuthData(authModel, fallbackUserId: existingUserId);

      return AuthResponse(
        accessToken: authModel.accessToken,
        refreshToken: authModel.refreshToken,
        expiresIn: authModel.expiresIn,
        userId: authModel.userId ?? existingUserId,
        currentRole: authModel.currentRole,
      );
    } catch (e) {
      throw Exception('Failed to verify OTP: $e');
    }
  }

  @override
  Future<void> switchRole(String role) async {
    try {
      await _remoteDataSource.switchRole(role);
      await _secureStorage.saveRole(role);
    } catch (e) {
      throw Exception('Failed to switch role: $e');
    }
  }

  @override
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _remoteDataSource.refreshToken(refreshToken);
      final authModel = AuthResponseModel.fromJson(response);
      final existingUserId = await _secureStorage.getUserId();

      await _saveAuthData(authModel, fallbackUserId: existingUserId);
      return true;
    } catch (e) {
      await _secureStorage.clearAll();
      return false;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } catch (e) {
      // Continue with local logout even if remote fails
    }

    await _secureStorage.clearAll();
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _secureStorage.isAuthenticated();
  }

  @override
  Future<String?> getCurrentUserId() async {
    return await _secureStorage.getUserId();
  }

  @override
  Future<String?> getCurrentUserRole() async {
    return await _secureStorage.getRole();
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final response = await _remoteDataSource.getCurrentUser();
      final userModel = UserModel.fromJson(response);

      return User(
        id: userModel.id,
        firebaseUid: userModel.firebaseUid,
        phoneNumber: userModel.phoneNumber,
        availableRoles: userModel.availableRoles,
        currentRole: userModel.currentRole,
        status: userModel.status,
        createdAt: userModel.createdAt,
        lastLogin: userModel.lastLogin,
      );
    } catch (e) {
      throw Exception('Failed to get current user: $e');
    }
  }

  /// Save authentication data to secure storage
  Future<void> _saveAuthData(
    AuthResponseModel authModel, {
    String? fallbackUserId,
  }) async {
    await _secureStorage.saveAccessToken(authModel.accessToken);
    await _secureStorage.saveRefreshToken(authModel.refreshToken);
    await _secureStorage.saveTokenType('bearer');
    await _secureStorage.saveExpiresIn(authModel.expiresIn);
    final userIdToStore = authModel.userId ?? fallbackUserId;
    if (userIdToStore != null && userIdToStore.isNotEmpty) {
      await _secureStorage.saveUserId(userIdToStore);
    }
    await _secureStorage.saveTokenCreatedAt(DateTime.now());

    if (authModel.currentRole != null) {
      await _secureStorage.saveRole(authModel.currentRole!);
    }
  }

  /// Get authorization header for API requests
  Future<String?> getAuthorizationHeader() async {
    return await _secureStorage.getAuthorizationHeader();
  }
}
