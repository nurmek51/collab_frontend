import '../entities/order.dart';
import '../repositories/orders_repository.dart';

/// Use case for getting order details by ID
class GetOrderDetails {
  final OrdersRepository repository;

  const GetOrderDetails(this.repository);

  Future<Order> call(String orderId) async {
    return await repository.getOrderDetails(orderId);
  }
}
