import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:equatable/equatable.dart';

/// Authentication state model
class AuthState extends Equatable {
  final String? accessToken;
  final String? tokenType;
  final int? expiresIn;
  final String? role;
  final String? userId;
  final DateTime? tokenCreatedAt;

  const AuthState({
    this.accessToken,
    this.tokenType,
    this.expiresIn,
    this.role,
    this.userId,
    this.tokenCreatedAt,
  });

  bool get isAuthenticated => accessToken != null && !isTokenExpired;

  bool get isTokenExpired {
    if (accessToken == null || expiresIn == null || tokenCreatedAt == null) {
      return true;
    }

    final expiryTime = tokenCreatedAt!.add(Duration(seconds: expiresIn!));
    return DateTime.now().isAfter(expiryTime);
  }

  AuthState copyWith({
    String? accessToken,
    String? tokenType,
    int? expiresIn,
    String? role,
    String? userId,
    DateTime? tokenCreatedAt,
  }) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      tokenCreatedAt: tokenCreatedAt ?? this.tokenCreatedAt,
    );
  }

  @override
  List<Object?> get props => [
    accessToken,
    tokenType,
    expiresIn,
    role,
    userId,
    tokenCreatedAt,
  ];
}

/// Secure token storage and management
class AuthStore {
  static const String _accessTokenKey = 'access_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _expiresInKey = 'expires_in';
  static const String _roleKey = 'role';
  static const String _userIdKey = 'user_id';
  static const String _tokenCreatedAtKey = 'token_created_at';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: false, // Disable encrypted SharedPreferences
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Set authentication tokens
  Future<void> setTokens({
    required String accessToken,
    required String tokenType,
    required int expiresIn,
    String? role,
    String? userId,
  }) async {
    final now = DateTime.now();

    try {
      // Save values individually to handle errors better
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _tokenTypeKey, value: tokenType);
      await _storage.write(key: _expiresInKey, value: expiresIn.toString());
      await _storage.write(
        key: _tokenCreatedAtKey,
        value: now.toIso8601String(),
      );
      if (role != null) {
        await _storage.write(key: _roleKey, value: role);
      }
      if (userId != null) {
        await _storage.write(key: _userIdKey, value: userId);
      }
    } catch (e) {
      print('Error saving tokens: $e');
      // Don't try fallback, just log the error
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  /// Get current role
  Future<String?> getRole() async {
    try {
      return await _storage.read(key: _roleKey);
    } catch (e) {
      print('Error getting role: $e');
      return null;
    }
  }

  /// Get user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  /// Get complete auth state
  Future<AuthState> getAuthState() async {
    try {
      // Get values individually to handle errors better
      final accessToken = await _storage.read(key: _accessTokenKey);
      final tokenType = await _storage.read(key: _tokenTypeKey);
      final expiresIn = await _storage.read(key: _expiresInKey);
      final role = await _storage.read(key: _roleKey);
      final userId = await _storage.read(key: _userIdKey);
      final tokenCreatedAt = await _storage.read(key: _tokenCreatedAtKey);

      return AuthState(
        accessToken: accessToken,
        tokenType: tokenType,
        expiresIn: expiresIn != null ? int.tryParse(expiresIn) : null,
        role: role,
        userId: userId,
        tokenCreatedAt: tokenCreatedAt != null
            ? DateTime.tryParse(tokenCreatedAt)
            : null,
      );
    } catch (e) {
      print('Error getting auth state: $e');
      return const AuthState();
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final authState = await getAuthState();
      return authState.isAuthenticated;
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    try {
      // Clear values individually to handle errors better
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _tokenTypeKey);
      await _storage.delete(key: _expiresInKey);
      await _storage.delete(key: _roleKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _tokenCreatedAtKey);
    } catch (e) {
      print('Error clearing tokens: $e');
    }
  }

  /// Get authorization header value
  Future<String?> getAuthorizationHeader() async {
    try {
      final accessToken = await getAccessToken();
      final tokenType = await _storage.read(key: _tokenTypeKey);

      if (accessToken != null) {
        return '${tokenType ?? 'Bearer'} $accessToken';
      }

      return null;
    } catch (e) {
      print('Error getting authorization header: $e');
      return null;
    }
  }

  /// Set role after authentication
  Future<void> setRole(String role) async {
    try {
      await _storage.write(key: _roleKey, value: role);
    } catch (e) {
      print('Error setting role: $e');
    }
  }

  /// Set user ID after authentication
  Future<void> setUserId(String userId) async {
    try {
      await _storage.write(key: _userIdKey, value: userId);
    } catch (e) {
      print('Error setting user ID: $e');
    }
  }
}
