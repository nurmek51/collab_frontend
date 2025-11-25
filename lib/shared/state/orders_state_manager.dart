import 'package:flutter/foundation.dart';
import '../../features/orders/domain/entities/order.dart';

/// Shared orders state manager for handling orders state across the app
/// Provides optimistic updates and centralizes order management
class OrdersStateManager extends ChangeNotifier {
  static OrdersStateManager? _instance;
  static OrdersStateManager get instance =>
      _instance ??= OrdersStateManager._();

  OrdersStateManager._();

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Set initial orders list
  void setOrders(List<Order> orders) {
    _orders = List.from(orders);
    _error = null;
    notifyListeners();
  }

  /// Add new order optimistically at the beginning of the list
  void addOrderOptimistically(Order order) {
    _orders = [order, ..._orders];
    notifyListeners();
  }

  /// Remove order if optimistic add failed
  void removeOrderOptimistically(String orderId) {
    _orders = _orders.where((order) => order.id != orderId).toList();
    notifyListeners();
  }

  /// Update existing order
  void updateOrder(Order updatedOrder) {
    final index = _orders.indexWhere((order) => order.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
      notifyListeners();
    }
  }

  /// Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error
  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Clear all orders (for logout/reset)
  void clear() {
    _orders = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Refresh orders by calling the provided refresh function
  Future<void> refreshOrders(Future<List<Order>> Function() refreshFn) async {
    try {
      setLoading(true);
      setError(null);
      final newOrders = await refreshFn();
      setOrders(newOrders);
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }
}
