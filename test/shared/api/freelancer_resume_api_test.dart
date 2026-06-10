import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:Collab/shared/api/client.dart';
import 'package:Collab/shared/api/freelancer_api.dart';
import 'package:Collab/shared/api/resume_models.dart';
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
  group('FreelancerApi resume endpoints', () {
    late Dio dio;
    late DioAdapter adapter;
    late FreelancerApi api;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      adapter = DioAdapter(dio: dio);
      dio.httpClientAdapter = adapter;
      api = FreelancerApi(ApiClient(_MemoryAuthStore(), dio: dio));
    });

    test('uploadResume sends multipart and parses response', () async {
      adapter.onPost(
        '/freelancers/profile/resume',
        (server) => server.reply(
          200,
          {
            'success': true,
            'data': {
              'has_resume': true,
              'resume_filename': 'resume.pdf',
              'resume_uploaded_at': '2026-06-09T12:00:00',
            },
            'error': null,
          },
        ),
        data: Matchers.any,
      );

      final result = await api.uploadResume(
        fileName: 'resume.pdf',
        fileBytes: [1, 2, 3, 4],
      );

      expect(result, isA<ResumeUploadResult>());
      expect(result.resumeFilename, 'resume.pdf');
      expect(result.hasResume, isTrue);
    });

    test('getResumeDownloadUrl parses signed url response', () async {
      adapter.onGet(
        '/freelancers/profile/resume',
        (server) => server.reply(
          200,
          {
            'success': true,
            'data': {
              'download_url': 'https://storage.googleapis.com/signed',
              'resume_filename': 'resume.pdf',
              'expires_in_seconds': 3600,
            },
            'error': null,
          },
        ),
      );

      final result = await api.getResumeDownloadUrl();

      expect(result.downloadUrl, contains('storage.googleapis.com'));
      expect(result.expiresInSeconds, 3600);
    });

    test('deleteResume parses deleted flag', () async {
      adapter.onDelete(
        '/freelancers/profile/resume',
        (server) => server.reply(
          200,
          {
            'success': true,
            'data': {'deleted': true},
            'error': null,
          },
        ),
      );

      final result = await api.deleteResume();
      expect(result.deleted, isTrue);
    });
  });
}
