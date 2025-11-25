import '../entities/order.dart';
import '../repositories/orders_repository.dart';

/// Use case for creating a new order
class CreateOrder {
  final OrdersRepository repository;

  const CreateOrder(this.repository);

  Future<Order> call({
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
    return await repository.createOrder(
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
  }
}
