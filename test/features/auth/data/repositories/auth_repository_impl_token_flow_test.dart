import 'package:flutter_test/flutter_test.dart';
import 'package:Collab/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:Collab/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:Collab/shared/storage/secure_storage_service.dart';

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  Map<String, dynamic>? verifyOtpResponse;
  Map<String, dynamic>? refreshResponse;
  bool failRefresh = false;

  @override
  Future<Map<String, dynamic>> getCurrentUser() async => <String, dynamic>{};

  @override
  Future<void> logout() async {}

  @override
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    if (failRefresh || refreshResponse == null) {
      throw Exception('refresh failed');
    }
    return refreshResponse!;
  }

  @override
  Future<void> sendOtp(String phoneNumber, {String? role}) async {}

  @override
  Future<void> switchRole(String role) async {}

  @override
  Future<Map<String, dynamic>> verifyOtp(
    String phoneNumber,
    String code, {
    String? firebaseToken,
  }) async {
    if (verifyOtpResponse == null) {
      throw Exception('verify response not configured');
    }
    return verifyOtpResponse!;
  }
}

class _FakeSecureStorageService extends SecureStorageService {
  String? accessToken;
  String? refreshToken;
  String? tokenType;
  int? expiresIn;
  String? userId;
  DateTime? createdAt;
  String? role;
  bool clearCalled = false;

  @override
  Future<void> clearAll() async {
    clearCalled = true;
    accessToken = null;
    refreshToken = null;
    tokenType = null;
    expiresIn = null;
    userId = null;
    createdAt = null;
    role = null;
  }

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<String?> getUserId() async => userId;

  @override
  Future<void> saveAccessToken(String token) async => accessToken = token;

  @override
  Future<void> saveExpiresIn(int expires) async => expiresIn = expires;

  @override
  Future<void> saveRefreshToken(String token) async => refreshToken = token;

  @override
  Future<void> saveRole(String nextRole) async => role = nextRole;

  @override
  Future<void> saveTokenCreatedAt(DateTime dateTime) async =>
      createdAt = dateTime;

  @override
  Future<void> saveTokenType(String type) async => tokenType = type;

  @override
  Future<void> saveUserId(String id) async => userId = id;
}

void main() {
  group('AuthRepositoryImpl token flow', () {
    late _FakeAuthRemoteDataSource remoteDataSource;
    late _FakeSecureStorageService secureStorage;
    late AuthRepositoryImpl repository;

    setUp(() {
      remoteDataSource = _FakeAuthRemoteDataSource();
      secureStorage = _FakeSecureStorageService();
      repository = AuthRepositoryImpl(
        remoteDataSource: remoteDataSource,
        secureStorage: secureStorage,
      );
    });

    test(
      'verifyOtp saves access/refresh token pair from response data',
      () async {
        remoteDataSource.verifyOtpResponse = {
          'success': true,
          'data': {
            'access_token': 'access_1',
            'refresh_token': 'refresh_1',
            'token_type': 'bearer',
            'expires_in': 86400,
          },
          'error': null,
        };

        final result = await repository.verifyOtp('+1234567890', '1234');

        expect(result.isValid, isTrue);
        expect(result.accessToken, equals('access_1'));
        expect(result.refreshToken, equals('refresh_1'));
        expect(secureStorage.accessToken, equals('access_1'));
        expect(secureStorage.refreshToken, equals('refresh_1'));
        expect(secureStorage.expiresIn, equals(86400));
        expect(secureStorage.tokenType, equals('bearer'));
        expect(secureStorage.createdAt, isNotNull);
      },
    );

    test('refreshToken rotates token pair and persists new values', () async {
      secureStorage.refreshToken = 'refresh_old';
      secureStorage.userId = 'user_123';

      remoteDataSource.refreshResponse = {
        'success': true,
        'data': {
          'access_token': 'access_2',
          'refresh_token': 'refresh_2',
          'token_type': 'bearer',
          'expires_in': 86400,
          'refresh_expires_in': 2592000,
        },
        'error': null,
      };

      final ok = await repository.refreshToken();

      expect(ok, isTrue);
      expect(secureStorage.accessToken, equals('access_2'));
      expect(secureStorage.refreshToken, equals('refresh_2'));
      expect(secureStorage.userId, equals('user_123'));
      expect(secureStorage.clearCalled, isFalse);
    });

    test('refreshToken clears session when refresh fails', () async {
      secureStorage.refreshToken = 'refresh_old';
      remoteDataSource.failRefresh = true;

      final ok = await repository.refreshToken();

      expect(ok, isFalse);
      expect(secureStorage.clearCalled, isTrue);
      expect(secureStorage.accessToken, isNull);
      expect(secureStorage.refreshToken, isNull);
    });
  });
}
