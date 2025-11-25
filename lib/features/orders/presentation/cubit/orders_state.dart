import '../../domain/entities/order.dart';

/// Base state for orders
abstract class OrdersState {
  const OrdersState();
}

/// Initial state
class OrdersInitial extends OrdersState {
  const OrdersInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is OrdersInitial;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'OrdersInitial()';
}

/// Loading state
class OrdersLoading extends OrdersState {
  const OrdersLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is OrdersLoading;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'OrdersLoading()';
}

/// Loaded state with orders data
class OrdersLoaded extends OrdersState {
  final List<Order> orders;

  const OrdersLoaded(this.orders);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrdersLoaded &&
        other.orders.length == orders.length &&
        other.orders.every((order) => orders.contains(order));
  }

  @override
  int get hashCode => orders.hashCode;

  @override
  String toString() => 'OrdersLoaded(orders: ${orders.length})';
}

/// Error state
class OrdersError extends OrdersState {
  final String message;
  final String? errorCode;

  const OrdersError(this.message, {this.errorCode});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrdersError &&
        other.message == message &&
        other.errorCode == errorCode;
  }

  @override
  int get hashCode => message.hashCode ^ errorCode.hashCode;

  @override
  String toString() => 'OrdersError(message: $message, code: $errorCode)';
}
