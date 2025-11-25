import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service wrapper for authentication tokens and sensitive data
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _expiresInKey = 'expires_in';
  static const String _roleKey = 'role';
  static const String _userIdKey = 'user_id';
  static const String _tokenCreatedAtKey = 'token_created_at';

  /// Save access token
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  /// Save refresh token
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Save token type
  Future<void> saveTokenType(String type) async {
    await _storage.write(key: _tokenTypeKey, value: type);
  }

  /// Get token type
  Future<String?> getTokenType() async {
    return await _storage.read(key: _tokenTypeKey);
  }

  /// Save expires in
  Future<void> saveExpiresIn(int expiresIn) async {
    await _storage.write(key: _expiresInKey, value: expiresIn.toString());
  }

  /// Get expires in
  Future<int?> getExpiresIn() async {
    final value = await _storage.read(key: _expiresInKey);
    return value != null ? int.tryParse(value) : null;
  }

  /// Save user role
  Future<void> saveRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  /// Get user role
  Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  /// Save token creation timestamp
  Future<void> saveTokenCreatedAt(DateTime createdAt) async {
    await _storage.write(
      key: _tokenCreatedAtKey,
      value: createdAt.toIso8601String(),
    );
  }

  /// Get token creation timestamp
  Future<DateTime?> getTokenCreatedAt() async {
    final value = await _storage.read(key: _tokenCreatedAtKey);
    return value != null ? DateTime.tryParse(value) : null;
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return false;

    // Check if token is expired
    final expiresIn = await getExpiresIn();
    final createdAt = await getTokenCreatedAt();

    if (expiresIn == null || createdAt == null) return false;

    final expiryTime = createdAt.add(Duration(seconds: expiresIn));
    return DateTime.now().isBefore(expiryTime);
  }

  /// Get authorization header
  Future<String?> getAuthorizationHeader() async {
    final accessToken = await getAccessToken();
    final tokenType = await getTokenType();

    if (accessToken != null) {
      return '${tokenType ?? 'Bearer'} $accessToken';
    }

    return null;
  }

  /// Clear all authentication data
  Future<void> clearAll() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenTypeKey);
    await _storage.delete(key: _expiresInKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _tokenCreatedAtKey);
  }

  /// Clear specific key
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// Read specific key
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// Write specific key-value pair
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
}
