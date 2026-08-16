import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:Collab/shared/api/auth_api.dart';
import 'package:Collab/shared/api/client.dart';
import 'package:Collab/shared/state/auth.dart';

class _AuthStore extends AuthStore {
  bool cleared = false;

  @override
  Future<String?> getAccessToken() async => 'access-token';

  @override
  Future<void> clearTokens() async => cleared = true;
}

void main() {
  test(
    'deletes the current account with an explicit confirmation body',
    () async {
      final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      final adapter = DioAdapter(dio: dio);
      dio.httpClientAdapter = adapter;
      final authStore = _AuthStore();

      adapter.onDelete(
        '/users/me',
        (server) => server.reply(200, {
          'success': true,
          'data': {'deleted': true},
          'error': null,
        }),
        data: {'confirm': true},
        headers: {'Authorization': 'Bearer access-token'},
      );

      await AuthApi(ApiClient(authStore, dio: dio), authStore).deleteAccount();

      expect(authStore.cleared, isTrue);
    },
  );
}
