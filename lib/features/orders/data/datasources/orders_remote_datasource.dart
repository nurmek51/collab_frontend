import '../../../../shared/network/dio_client.dart';

/// Abstract remote data source for orders
abstract class OrdersRemoteDataSource {
  /// Get all orders for current user
  Future<List<Map<String, dynamic>>> getMyOrders();

  /// Get order details by ID
  Future<Map<String, dynamic>> getOrderById(String orderId);

  /// Create new order
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData);

  /// Update existing order
  Future<Map<String, dynamic>> updateOrder(
    String orderId,
    Map<String, dynamic> orderData,
  );

  /// Delete order
  Future<void> deleteOrder(String orderId);

  /// Apply to order
  Future<void> applyToOrder(String orderId, String coverLetter);

  /// Get applications for order
  Future<List<Map<String, dynamic>>> getOrderApplications(String orderId);
}

/// Implementation of orders remote data source
class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final DioClient _dioClient;

  OrdersRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<Map<String, dynamic>>> getMyOrders() async {
    final response = await _dioClient.get('/orders/my');
    return List<Map<String, dynamic>>.from(response.data as List);
  }

  @override
  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    final response = await _dioClient.get('/orders/$orderId');
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    final response = await _dioClient.post('/orders', data: orderData);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> updateOrder(
    String orderId,
    Map<String, dynamic> orderData,
  ) async {
    final response = await _dioClient.put('/orders/$orderId', data: orderData);
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    await _dioClient.delete('/orders/$orderId');
  }

  @override
  Future<void> applyToOrder(String orderId, String coverLetter) async {
    final data = {'cover_letter': coverLetter};
    await _dioClient.post('/orders/$orderId/apply', data: data);
  }

  @override
  Future<List<Map<String, dynamic>>> getOrderApplications(
    String orderId,
  ) async {
    final response = await _dioClient.get('/orders/$orderId/applications');
    return List<Map<String, dynamic>>.from(response.data as List);
  }
}
