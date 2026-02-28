import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:Collab/shared/api/client.dart';
import 'package:Collab/shared/state/auth.dart';

class _MemoryAuthStore extends AuthStore {
  String? accessToken;
  String? refreshToken;
  String? tokenType;
  int? expiresIn;
  int? refreshExpiresIn;
  String? role;
  String? userId;
  DateTime? createdAt;
  bool cleared = false;

  @override
  Future<void> clearTokens() async {
    cleared = true;
    accessToken = null;
    refreshToken = null;
    tokenType = null;
    expiresIn = null;
    refreshExpiresIn = null;
    role = null;
    userId = null;
    createdAt = null;
  }

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<AuthState> getAuthState() async {
    return AuthState(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
      refreshExpiresIn: refreshExpiresIn,
      role: role,
      userId: userId,
      tokenCreatedAt: createdAt,
    );
  }

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required int expiresIn,
    int? refreshExpiresIn,
    String? role,
    String? userId,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
    this.tokenType = tokenType;
    this.expiresIn = expiresIn;
    this.refreshExpiresIn = refreshExpiresIn;
    this.role = role;
    this.userId = userId;
    createdAt = DateTime.now();
  }
}

void main() {
  group('ApiClient refresh-retry', () {
    test(
      'refreshes token on 401 and retries original request successfully',
      () async {
        final dio = Dio(
          BaseOptions(
            baseUrl: 'https://example.test',
            headers: {'Content-Type': 'application/json'},
          ),
        );
        final adapter = DioAdapter(dio: dio);
        dio.httpClientAdapter = adapter;

        final store = _MemoryAuthStore()
          ..accessToken = 'old_access'
          ..refreshToken = 'old_refresh'
          ..tokenType = 'bearer'
          ..expiresIn = 300;

        adapter.onGet(
          '/protected',
          (server) => server.reply(401, {'detail': 'Unauthorized'}),
          headers: {'Authorization': 'Bearer old_access'},
        );

        adapter.onPost(
          '/auth/refresh',
          (server) => server.reply(200, {
            'success': true,
            'data': {
              'access_token': 'new_access',
              'refresh_token': 'new_refresh',
              'token_type': 'bearer',
              'expires_in': 86400,
              'refresh_expires_in': 2592000,
            },
            'error': null,
          }),
          data: {'refresh_token': 'old_refresh'},
        );

        adapter.onGet(
          '/protected',
          (server) => server.reply(200, {
            'success': true,
            'data': {'ok': true},
            'error': null,
          }),
          headers: {'Authorization': 'Bearer new_access'},
        );

        final client = ApiClient(store, dio: dio);
        final response = await client.get<Map<String, dynamic>>(
          '/protected',
          fromJson: (data) => data as Map<String, dynamic>,
        );

        expect(response['ok'], isTrue);
        expect(store.accessToken, equals('new_access'));
        expect(store.refreshToken, equals('new_refresh'));
        expect(store.cleared, isFalse);
      },
    );
  });
}
