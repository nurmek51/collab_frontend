import '../../domain/entities/order.dart';

/// Base state for order details
abstract class OrderDetailsState {
  const OrderDetailsState();
}

/// Initial state
class OrderDetailsInitial extends OrderDetailsState {
  const OrderDetailsInitial();

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is OrderDetailsInitial;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'OrderDetailsInitial()';
}

/// Loading state
class OrderDetailsLoading extends OrderDetailsState {
  const OrderDetailsLoading();

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is OrderDetailsLoading;
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'OrderDetailsLoading()';
}

/// Loaded state with order details
class OrderDetailsLoaded extends OrderDetailsState {
  final Order order;

  const OrderDetailsLoaded(this.order);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderDetailsLoaded && other.order == order;
  }

  @override
  int get hashCode => order.hashCode;

  @override
  String toString() => 'OrderDetailsLoaded(order: ${order.id})';
}

/// Error state
class OrderDetailsError extends OrderDetailsState {
  final String message;
  final String? errorCode;

  const OrderDetailsError(this.message, {this.errorCode});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderDetailsError &&
        other.message == message &&
        other.errorCode == errorCode;
  }

  @override
  int get hashCode => message.hashCode ^ errorCode.hashCode;

  @override
  String toString() => 'OrderDetailsError(message: $message, code: $errorCode)';
}
