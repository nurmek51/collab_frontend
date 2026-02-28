/// Application configuration constants
class AppConfig {
  // Environment-based configuration
  static const bool isDebug = bool.fromEnvironment('DEBUG', defaultValue: true);
  static const String _envBaseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: '',
  );

  // Base URL configuration
  static const String _debugBaseUrl =
      'https://collab-api-810993564533.europe-north2.run.app/';
  static const String _productionBaseUrl =
      'https://collab-api-810993564533.europe-north2.run.app/';

  /// Get the appropriate base URL based on environment
  static String get baseUrl {
    if (_envBaseUrl.trim().isNotEmpty) {
      return _normalizeBaseUrl(_envBaseUrl);
    }

    return isDebug ? _debugBaseUrl : _productionBaseUrl;
  }

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }

  // API endpoints
  static const String apiVersion = '/api/v1';

  // Network timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
