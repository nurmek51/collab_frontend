/// Tracks admin panel authentication for the current browser session.
/// Avoids re-validating admin role on every in-panel navigation.
class AdminSession {
  bool _isAuthenticated = false;
  DateTime? _verifiedAt;
  static const Duration _verificationTtl = Duration(minutes: 30);

  bool get isAuthenticated {
    if (!_isAuthenticated) {
      return false;
    }
    final verifiedAt = _verifiedAt;
    if (verifiedAt == null) {
      return false;
    }
    return DateTime.now().difference(verifiedAt) < _verificationTtl;
  }

  void markAuthenticated() {
    _isAuthenticated = true;
    _verifiedAt = DateTime.now();
  }

  void clear() {
    _isAuthenticated = false;
    _verifiedAt = null;
  }
}
