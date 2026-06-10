import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:Collab/shared/api/auth_api.dart';
import 'package:Collab/shared/api/avatar_models.dart';
import 'package:Collab/shared/api/client.dart';
import 'package:Collab/shared/state/auth.dart';

class _MemoryAuthStore extends AuthStore {
  String? accessToken = 'test-token';

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<void> clearTokens() async {
    accessToken = null;
  }

  @override
  Future<AuthState> getAuthState() async => const AuthState();

  @override
  Future<String?> getRefreshToken() async => null;

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
  }
}

void main() {
  group('AuthApi avatar endpoints', () {
    late Dio dio;
    late DioAdapter adapter;
    late AuthApi api;
    late _MemoryAuthStore authStore;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      adapter = DioAdapter(dio: dio);
      dio.httpClientAdapter = adapter;
      authStore = _MemoryAuthStore();
      api = AuthApi(ApiClient(authStore, dio: dio), authStore);
    });

    test('uploadAvatar parses response', () async {
      adapter.onPost(
        '/users/me/avatar',
        (server) => server.reply(
          200,
          {
            'success': true,
            'data': {
              'has_avatar': true,
              'avatar_uploaded_at': '2026-06-09T18:00:00',
            },
          },
        ),
        data: Matchers.any,
      );

      final result = await api.uploadAvatar(
        fileName: 'avatar.jpg',
        fileBytes: [1, 2, 3],
      );

      expect(result.hasAvatar, isTrue);
      expect(result.avatarUploadedAt, isNotNull);
    });

    test('getMyAvatarDownloadUrl parses response', () async {
      adapter.onGet(
        '/users/me/avatar',
        (server) => server.reply(
          200,
          {
            'success': true,
            'data': {
              'download_url': 'https://storage.googleapis.com/avatar.jpg',
              'expires_in_seconds': 3600,
            },
          },
        ),
      );

      final result = await api.getMyAvatarDownloadUrl();

      expect(result.downloadUrl, contains('storage.googleapis.com'));
      expect(result.expiresInSeconds, 3600);
    });

    test('getUserAvatarDownloadUrl parses response', () async {
      adapter.onGet(
        '/users/user-123/avatar',
        (server) => server.reply(
          200,
          {
            'success': true,
            'data': {
              'download_url': 'https://storage.googleapis.com/other.jpg',
              'expires_in_seconds': 1800,
            },
          },
        ),
      );

      final result = await api.getUserAvatarDownloadUrl('user-123');

      expect(result, isA<AvatarDownloadResult>());
      expect(result.expiresInSeconds, 1800);
    });

    test('deleteAvatar parses response', () async {
      adapter.onDelete(
        '/users/me/avatar',
        (server) => server.reply(
          200,
          {
            'success': true,
            'data': {'has_avatar': false},
          },
        ),
      );

      final result = await api.deleteAvatar();

      expect(result.deleted, isTrue);
    });
  });
}
