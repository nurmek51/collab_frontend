import 'dart:async';
import 'token_manager.dart';

/// Background token refresh manager
/// Automatically refreshes tokens before they expire to ensure seamless user experience
class BackgroundRefreshManager {
  static BackgroundRefreshManager? _instance;
  static BackgroundRefreshManager get instance =>
      _instance ??= BackgroundRefreshManager._();

  BackgroundRefreshManager._();

  final TokenManager _tokenManager = TokenManager.instance;
  Timer? _refreshTimer;
  bool _isActive = false;

  // Check every minute for token refresh needs
  static const Duration _checkInterval = Duration(minutes: 1);

  // Refresh token when it expires within 10 minutes
  static const int _backgroundRefreshThresholdSeconds = 600; // 10 minutes

  /// Start background refresh monitoring
  void start() {
    if (_isActive) {
      print('[BACKGROUND_REFRESH] Already active, skipping start');
      return;
    }

    _isActive = true;
    print('[BACKGROUND_REFRESH] Starting background token refresh manager');

    _refreshTimer = Timer.periodic(_checkInterval, (_) => _checkAndRefresh());

    // Perform immediate check
    _checkAndRefresh();
  }

  /// Stop background refresh monitoring
  void stop() {
    if (!_isActive) {
      print('[BACKGROUND_REFRESH] Already stopped, skipping stop');
      return;
    }

    _refreshTimer?.cancel();
    _refreshTimer = null;
    _isActive = false;
    print('[BACKGROUND_REFRESH] Stopped background token refresh manager');
  }

  /// Check if refresh is needed and perform it
  Future<void> _checkAndRefresh() async {
    try {
      // Check if user has tokens
      final accessToken = await _tokenManager.accessToken;
      final refreshToken = await _tokenManager.refreshToken;

      if (accessToken == null || refreshToken == null) {
        print('[BACKGROUND_REFRESH] No tokens available, skipping check');
        return;
      }

      // Get remaining time until expiry
      final expiresInSeconds = await _tokenManager.getTokenExpiresInSeconds();

      if (expiresInSeconds == null) {
        print('[BACKGROUND_REFRESH] No expiration info, skipping check');
        return;
      }

      print('[BACKGROUND_REFRESH] Token expires in $expiresInSeconds seconds');

      // Refresh if token expires within the background threshold
      if (expiresInSeconds <= _backgroundRefreshThresholdSeconds) {
        print(
          '[BACKGROUND_REFRESH] Token expiring within threshold, refreshing...',
        );

        try {
          await _tokenManager.refreshTokenProactively();
          print('[BACKGROUND_REFRESH] Token refreshed successfully');
        } catch (error) {
          print('[BACKGROUND_REFRESH] Token refresh failed: $error');

          // Stop background refresh if token refresh consistently fails
          if (expiresInSeconds <= 60) {
            // Less than 1 minute remaining
            print(
              '[BACKGROUND_REFRESH] Token expires very soon and refresh failed, stopping background refresh',
            );
            stop();
          }
        }
      }
    } catch (error) {
      print('[BACKGROUND_REFRESH] Check failed: $error');
    }
  }

  /// Check if background refresh is active
  bool get isActive => _isActive;

  /// Get current refresh timer interval
  Duration get checkInterval => _checkInterval;

  /// Get background refresh threshold in seconds
  int get refreshThresholdSeconds => _backgroundRefreshThresholdSeconds;

  /// Manually trigger a refresh check (useful for testing)
  Future<void> triggerCheck() async {
    if (!_isActive) {
      print('[BACKGROUND_REFRESH] Not active, cannot trigger check');
      return;
    }

    print('[BACKGROUND_REFRESH] Manually triggering refresh check');
    await _checkAndRefresh();
  }

  /// Get status information for debugging
  Map<String, dynamic> getStatus() {
    return {
      'is_active': _isActive,
      'check_interval_minutes': _checkInterval.inMinutes,
      'refresh_threshold_seconds': _backgroundRefreshThresholdSeconds,
      'has_timer': _refreshTimer != null,
    };
  }
}

/// Extension to easily manage background refresh with authentication state
extension BackgroundRefreshAuthExtension on BackgroundRefreshManager {
  /// Start background refresh when user logs in
  void startOnLogin() {
    print('[BACKGROUND_REFRESH] Starting due to user login');
    start();
  }

  /// Stop background refresh when user logs out
  void stopOnLogout() {
    print('[BACKGROUND_REFRESH] Stopping due to user logout');
    stop();
  }

  /// Restart background refresh (useful after app resume)
  void restart() {
    print('[BACKGROUND_REFRESH] Restarting background refresh');
    stop();
    start();
  }
}
