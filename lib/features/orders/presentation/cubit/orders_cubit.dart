import 'package:flutter_bloc/flutter_bloc.dart';
import 'orders_state.dart';
import '../../domain/usecases/get_my_orders.dart';

/// Cubit for managing orders list
class OrdersCubit extends Cubit<OrdersState> {
  final GetMyOrders _getMyOrders;

  OrdersCubit(this._getMyOrders) : super(const OrdersInitial());

  /// Load user's orders
  Future<void> loadOrders() async {
    emit(const OrdersLoading());

    try {
      final orders = await _getMyOrders();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError('Failed to load orders: $e'));
    }
  }

  /// Refresh orders
  Future<void> refreshOrders() async {
    // Keep current state while refreshing
    if (state is OrdersLoaded) {
      try {
        final orders = await _getMyOrders();
        emit(OrdersLoaded(orders));
      } catch (e) {
        emit(OrdersError('Failed to refresh orders: $e'));
      }
    } else {
      await loadOrders();
    }
  }

  /// Clear state
  void clear() {
    emit(const OrdersInitial());
  }
}
