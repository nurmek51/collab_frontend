import '../entities/order.dart';
import '../entities/feed_item.dart';

/// Abstract repository for orders operations
abstract class OrdersRepository {
  /// Get user's orders with pagination
  Future<List<Order>> getMyOrders({int limit = 20, int offset = 0});

  /// Get order details by ID
  Future<Order> getOrderDetails(String orderId);

  /// Get orders feed for freelancers with pagination
  Future<List<FeedItem>> getOrdersFeed({int limit = 20, int offset = 0});

  /// Create a new order with client onboarding
  Future<Order> createOrder({
    required String companyName,
    required String companyPosition,
    required String orderDescription,
    String? firstName,
    String? lastName,
    String? title,
    List<String>? specializations,
    Map<String, dynamic>? orderCondition,
    String? requirements,
    String? chatLink,
  });
}
