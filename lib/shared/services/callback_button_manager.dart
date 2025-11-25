import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/services/api_service.dart';
import '../../core/services/callback_state_manager.dart';
import '../di/service_locator.dart';

/// Manager for callback button state and debouncing
class CallbackButtonManager extends ChangeNotifier {
  static final Map<String, CallbackButtonManager> _instances = {};

  static CallbackButtonManager getInstance(String key) {
    return _instances.putIfAbsent(key, () => CallbackButtonManager._());
  }

  CallbackButtonManager._();

  bool _isPending = false;
  String? _error;
  Timer? _timeoutTimer;
  static const Duration _timeoutDuration = Duration(seconds: 10);

  bool get isPending => _isPending;
  String? get error => _error;

  /// Request callback with debouncing and timeout protection
  Future<void> requestCallback({
    required VoidCallback onSuccess,
    required Function(String) onError,
    String? idempotencyToken,
  }) async {
    // Prevent multiple simultaneous requests
    if (_isPending) return;

    _setPending(true);
    _clearError();

    try {
      final apiService = sl<ApiService>();

      // Set timeout
      _timeoutTimer = Timer(_timeoutDuration, () {
        if (_isPending) {
          _setPending(false);
          _setError('Таймаут запроса');
          onError('Таймаут запроса. Попробуйте еще раз.');
        }
      });

      await apiService.requestHelp();
      await CallbackStateManager.instance.setCallbackRequested();

      // Cancel timeout timer if request completed successfully
      _timeoutTimer?.cancel();

      if (_isPending) {
        // Only proceed if not timed out
        _setPending(false);
        onSuccess();
      }
    } catch (e) {
      _timeoutTimer?.cancel();
      _setPending(false);
      final errorMessage = 'Ошибка при заказе звонка: $e';
      _setError(errorMessage);
      onError(errorMessage);
    }
  }

  void _setPending(bool pending) {
    _isPending = pending;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset state (useful for cleanup)
  void reset() {
    _timeoutTimer?.cancel();
    _isPending = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  /// Remove instance from cache
  static void disposeInstance(String key) {
    final instance = _instances.remove(key);
    instance?.reset();
  }
}
