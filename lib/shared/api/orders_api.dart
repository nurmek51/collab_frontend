import 'client.dart';
import '../../features/orders/data/models/order_feed_model.dart';

/// Orders API endpoints
class OrdersApi {
  final ApiClient _client;

  OrdersApi(this._client);

  /// Get list of approved orders (for freelancers)
  Future<OrdersFeedResponse> getOrders({int page = 1, int size = 20}) async {
    final data = await _client.get<Map<String, dynamic>>(
      '/orders/',
      queryParameters: {'page': page, 'size': size},
      fromJson: (d) => d as Map<String, dynamic>,
    );

    // Parse into a typed response model
    return OrdersFeedResponse.fromJson(data);
  }

  /// Get order details by ID
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    return await _client.get<Map<String, dynamic>>(
      '/orders/$orderId',
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Create a new order
  Future<Map<String, dynamic>> createOrder({
    required String name,
    required String surname,
    required String companyName,
    required String companyPosition,
    required String orderDescription,
    required String orderTitle,
    required Map<String, dynamic> orderCondition,
    required String requirements,
    required List<String> orderSpecializations,
    required String chatLink,
  }) async {
    return await _client.post<Map<String, dynamic>>(
      '/orders/create',
      data: {
        'name': name,
        'surname': surname,
        'company_name': companyName,
        'company_position': companyPosition,
        'order_description': orderDescription,
        'order_title': orderTitle,
        'order_condition': orderCondition,
        'requirements': requirements,
        'order_specializations': orderSpecializations,
        'chat_link': chatLink,
      },
      fromJson: (data) => data as Map<String, dynamic>,
    );
  }

  /// Get client's own orders
  Future<List<dynamic>> getMyOrders({int limit = 20, int offset = 0}) async {
    final response = await _client.get<Map<String, dynamic>>(
      '/orders/my',
      queryParameters: {'limit': limit, 'offset': offset},
      fromJson: (data) => data as Map<String, dynamic>,
    );

    // The response should be the envelope with data containing the list
    if (response['success'] == true && response['data'] is List) {
      return response['data'] as List<dynamic>;
    }

    return [];
  }
}
