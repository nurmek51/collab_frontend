import 'package:flutter_bloc/flutter_bloc.dart';
import 'order_details_state.dart';
import '../../domain/usecases/get_order_details.dart';

/// Cubit for managing order details
class OrderDetailsCubit extends Cubit<OrderDetailsState> {
  final GetOrderDetails _getOrderDetails;

  OrderDetailsCubit(this._getOrderDetails) : super(const OrderDetailsInitial());

  /// Load order details
  Future<void> loadOrderDetails(String orderId) async {
    emit(const OrderDetailsLoading());

    try {
      final order = await _getOrderDetails(orderId);
      emit(OrderDetailsLoaded(order));
    } catch (e) {
      emit(OrderDetailsError('Failed to load order details: $e'));
    }
  }

  /// Clear state
  void clear() {
    emit(const OrderDetailsInitial());
  }
}
