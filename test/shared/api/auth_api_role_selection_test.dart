import 'package:Collab/shared/api/auth_api.dart';
import 'package:Collab/shared/api/client.dart';
import 'package:Collab/shared/state/auth.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

class _MemoryAuthStore extends AuthStore {
  String? accessToken;
  String? refreshToken;
  String? role = 'freelancer';
  bool clearRoleCalled = false;

  @override
  Future<String?> getAccessToken() async => accessToken;

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
    if (role != null) this.role = role;
  }

  @override
  Future<void> clearRole() async {
    clearRoleCalled = true;
    role = null;
  }
}

void main() {
  test(
    'OTP can defer backend role until the pre-login choice is applied',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      final adapter = DioAdapter(dio: dio);
      dio.httpClientAdapter = adapter;
      final authStore = _MemoryAuthStore();
      final api = AuthApi(ApiClient(authStore, dio: dio), authStore);

      adapter.onPost(
        '/auth/verify-otp',
        (server) => server.reply(200, {
          'success': true,
          'data': {
            'access_token': 'access-token',
            'refresh_token': 'refresh-token',
            'token_type': 'bearer',
            'expires_in': 86400,
            'current_role': 'freelancer',
          },
          'error': null,
        }),
        data: {'phone_number': '+77001234567', 'code': '123456'},
      );

      await api.verifyOtp(
        phoneNumber: '+77001234567',
        code: '123456',
        deferRoleSelection: true,
      );

      expect(authStore.accessToken, 'access-token');
      expect(authStore.clearRoleCalled, isTrue);
      expect(authStore.role, isNull);
    },
  );
}
