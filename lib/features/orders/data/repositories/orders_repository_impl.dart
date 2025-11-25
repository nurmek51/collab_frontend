import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/feed_item.dart';
import '../../domain/repositories/orders_repository.dart';
import '../models/order_model.dart';
import '../models/feed_item_model.dart';

/// Implementation of OrdersRepository
class OrdersRepositoryImpl implements OrdersRepository {
  final ApiService apiService;

  const OrdersRepositoryImpl(this.apiService);

  @override
  Future<List<Order>> getMyOrders({int limit = 20, int offset = 0}) async {
    try {
      final response = await apiService.getMyOrders(
        limit: limit,
        offset: offset,
      );
      return response
          .map((json) => OrderModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list for now - in production, proper error handling would be needed
      debugPrint('❌ [OrdersRepositoryImpl] Error fetching my orders: $e');
      return [];
    }
  }

  @override
  Future<List<FeedItem>> getOrdersFeed({int limit = 20, int offset = 0}) async {
    try {
      final response = await apiService.getOrdersFeed(
        limit: limit,
        offset: offset,
      );
      return response
          .map((json) => FeedItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list for now - in production, proper error handling would be needed
      debugPrint('❌ [OrdersRepositoryImpl] Error fetching orders feed: $e');
      return [];
    }
  }

  @override
  Future<Order> getOrderDetails(String orderId) async {
    try {
      final response = await apiService.getOrderDetails(orderId);
      // If response contains 'data', use it, else use response directly
      final Map<String, dynamic> orderJson =
          response['data'] is Map<String, dynamic>
          ? response['data'] as Map<String, dynamic>
          : response;
      return OrderModel.fromJson(orderJson);
    } catch (e) {
      debugPrint('❌ [OrdersRepositoryImpl] Error fetching order details: $e');
      rethrow; // Rethrow the exception after logging it
    }
  }

  @override
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
  }) async {
    try {
      final response = await apiService.createOrder(
        companyName: companyName,
        companyPosition: companyPosition,
        orderDescription: orderDescription,
        firstName: firstName,
        lastName: lastName,
        title: title,
        specializations: specializations,
        orderCondition: orderCondition,
        requirements: requirements,
        chatLink: chatLink,
      );

      return OrderModel.fromJson(response);
    } catch (e) {
      debugPrint('❌ [OrdersRepositoryImpl] Error creating order: $e');
      rethrow; // Rethrow the exception after logging it
    }
  }
}
