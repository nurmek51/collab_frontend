import 'client.dart';

class AdminApi {
  final ApiClient _client;

  AdminApi(this._client);

  Future<Map<String, dynamic>> getPendingOrders({
    int page = 1,
    int size = 20,
  }) async {
    return await _client.get<Map<String, dynamic>>(
      '/admin/orders/pending',
      queryParameters: {'page': page, 'size': size},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> getAllOrders({
    int page = 1,
    int size = 20,
  }) async {
    return await _client.get<Map<String, dynamic>>(
      '/orders/',
      queryParameters: {'page': page, 'size': size},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> getOrdersByStatus({
    required String status,
    int page = 1,
    int size = 20,
  }) async {
    return await _client.get<Map<String, dynamic>>(
      '/admin/orders',
      queryParameters: {'status': status, 'page': page, 'size': size},
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Complete and update an order
  Future<Map<String, dynamic>> completeOrder({
    required String orderId,
    required String orderDescription,
    String? orderTitle,
    String? chatLink,
    Map<String, dynamic>? contracts,
    List<Map<String, dynamic>>? orderSpecializations,
  }) async {
    return await _client.post<Map<String, dynamic>>(
      '/admin/orders/$orderId/complete',
      data: {
        'order_description': orderDescription,
        if (orderTitle != null) 'order_title': orderTitle,
        if (chatLink != null) 'chat_link': chatLink,
        if (contracts != null) 'contracts': contracts,
        if (orderSpecializations != null)
          'order_specializations': orderSpecializations,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }
}
