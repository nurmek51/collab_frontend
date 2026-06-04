import 'package:flutter/foundation.dart';

/// Notifies [GoRouter] when auth state changes so redirects re-run.
class AuthRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
