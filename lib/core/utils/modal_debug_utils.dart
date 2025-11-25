import 'package:flutter/material.dart';

/// Debug utilities for modal troubleshooting
class ModalDebugUtils {
  /// Check if context has problematic stacking elements
  static void analyzeContext(BuildContext context) {
    debugPrint('=== Modal Context Analysis ===');

    // Check media query and viewport
    final mediaQuery = MediaQuery.of(context);
    debugPrint('  Viewport: ${mediaQuery.size}');
    debugPrint('  ViewInsets: ${mediaQuery.viewInsets}');
    debugPrint('  Padding: ${mediaQuery.padding}');

    // Check for Navigator state
    final navigator = Navigator.maybeOf(context);
    if (navigator != null) {
      debugPrint('  Navigator found: ${navigator.runtimeType}');
    }

    // Check for Scaffold state
    final scaffold = Scaffold.maybeOf(context);
    if (scaffold != null) {
      debugPrint('  Scaffold found: ${scaffold.runtimeType}');
    }

    debugPrint('=== End Analysis ===');
  }

  /// Log modal state changes for debugging
  static void logModalState(String state, [Map<String, dynamic>? data]) {
    debugPrint('MODAL[$state]: ${data?.toString() ?? ''}');
  }

  /// Log error with context information
  static void logError(String error, [dynamic stackTrace]) {
    debugPrint('MODAL[ERROR]: $error');
    if (stackTrace != null) {
      debugPrint('MODAL[STACK]: $stackTrace');
    }
  }

  /// Check if context is valid for modal operations
  static bool isContextValid(BuildContext context) {
    try {
      final mediaQuery = MediaQuery.of(context);
      final navigator = Navigator.maybeOf(context);
      debugPrint(
        'MODAL[CONTEXT_CHECK]: MediaQuery: ${mediaQuery.size}, Navigator: ${navigator != null}',
      );
      return true;
    } catch (e) {
      debugPrint('MODAL[CONTEXT_CHECK_FAILED]: $e');
      return false;
    }
  }
}
