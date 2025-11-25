import 'client.dart';

class ClientsApi {
  final ApiClient _client;

  ClientsApi(this._client);

  Future<Map<String, dynamic>> getClientById(String clientId) async {
    return await _client.get<Map<String, dynamic>>(
      '/clients/$clientId',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}
