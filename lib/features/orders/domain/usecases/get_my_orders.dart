import '../entities/order.dart';
import '../repositories/orders_repository.dart';

/// Use case for getting user's orders
class GetMyOrders {
  final OrdersRepository repository;

  const GetMyOrders(this.repository);

  Future<List<Order>> call({int limit = 20, int offset = 0}) async {
    return await repository.getMyOrders(limit: limit, offset: offset);
  }
}
