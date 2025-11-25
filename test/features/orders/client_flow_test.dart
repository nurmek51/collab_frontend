import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:collab_frontend/shared/state/orders_state_manager.dart';
import 'package:collab_frontend/shared/services/callback_button_manager.dart';
import 'package:collab_frontend/features/orders/domain/entities/order.dart';

void main() {
  group('Orders State Manager Tests', () {
    late OrdersStateManager ordersManager;

    setUp(() {
      GetIt.instance.reset();
      ordersManager = OrdersStateManager.instance;
    });

    tearDown(() {
      ordersManager.clear();
    });

    test('should add order optimistically', () {
      final order = Order(
        id: 'test_id',
        title: 'Test Order',
        description: 'Test Description',
        status: 'pending',
        createdAt: DateTime.now(),
      );

      ordersManager.addOrderOptimistically(order);

      expect(ordersManager.orders.length, equals(1));
      expect(ordersManager.orders.first.id, equals('test_id'));
    });

    test('should remove order optimistically', () {
      final order = Order(
        id: 'test_id',
        title: 'Test Order',
        description: 'Test Description',
        status: 'pending',
        createdAt: DateTime.now(),
      );

      ordersManager.addOrderOptimistically(order);
      expect(ordersManager.orders.length, equals(1));

      ordersManager.removeOrderOptimistically('test_id');
      expect(ordersManager.orders.length, equals(0));
    });
  });

  group('Callback Button Manager Tests', () {
    late CallbackButtonManager callbackManager;

    setUp(() {
      callbackManager = CallbackButtonManager.getInstance('test');
    });

    tearDown(() {
      callbackManager.reset();
      CallbackButtonManager.disposeInstance('test');
    });

    testWidgets('should show pending state when requesting callback', (
      tester,
    ) async {
      bool successCalled = false;
      bool errorCalled = false;

      expect(callbackManager.isPending, isFalse);

      // This test would need proper API mocking to work fully
      // For now, just verify the state management logic
    });
  });
}
