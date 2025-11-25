import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'responsive_wrapper.dart';

/// A wrapper that conditionally applies ResponsiveWrapper based on the current route.
/// Admin routes bypass the responsive wrapper to display as full web applications.
/// All other routes get the responsive wrapper for mobile-first design.
class ConditionalResponsiveWrapper extends StatelessWidget {
  const ConditionalResponsiveWrapper({
    super.key,
    required this.child,
    this.backgroundColor,
  });

  final Widget child;
  final Color? backgroundColor;

  bool _isAdminRoute() {
    if (kIsWeb) {
      // For web, check the current URL
      try {
        final currentUrl = Uri.base.toString();
        return currentUrl.contains('/admin');
      } catch (e) {
        return false;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isAdminRoute = _isAdminRoute();

    if (isAdminRoute) {
      // Admin routes: return child directly without responsive wrapper
      return child;
    }

    // Non-admin routes: apply responsive wrapper
    return ResponsiveWrapper(
      backgroundColor: backgroundColor ?? const Color(0xFFF1F2F1),
      child: child,
    );
  }
}
