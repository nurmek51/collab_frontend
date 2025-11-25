import '../api/freelancer_api.dart';
import '../state/auth.dart';

/// Freelancer profile status management with intelligent caching
class FreelancerProfileStatusManager {
  final FreelancerApi _freelancerApi;
  final AuthStore _authStore;

  // Cache for profile data
  Map<String, dynamic>? _cachedProfile;
  DateTime? _lastFetched;
  static const Duration _cacheTimeout = Duration(minutes: 5);

  FreelancerProfileStatusManager(this._freelancerApi, this._authStore);

  /// Check if cached data is still valid
  bool get _isCacheValid {
    return _cachedProfile != null &&
        _lastFetched != null &&
        DateTime.now().difference(_lastFetched!) < _cacheTimeout;
  }

  /// Fetch profile data from API (always makes network call)
  Future<Map<String, dynamic>?> _fetchProfileFromApi() async {
    try {
      final profile = await _freelancerApi.getProfile();
      _cachedProfile = profile;
      _lastFetched = DateTime.now();
      return profile;
    } catch (e) {
      // Don't update cache if API call fails
      return null;
    }
  }

  /// Get profile data with caching (avoids unnecessary API calls)
  Future<Map<String, dynamic>?> _getProfileWithCache() async {
    final role = await _authStore.getRole();
    if (role != 'freelancer') {
      return null;
    }

    // Return cached data if still valid
    if (_isCacheValid) {
      return _cachedProfile;
    }

    // Fetch fresh data if cache is invalid or expired
    return await _fetchProfileFromApi();
  }

  /// Force refresh profile data (always fetches from API)
  Future<Map<String, dynamic>?> refreshProfile() async {
    final role = await _authStore.getRole();
    if (role != 'freelancer') {
      return null;
    }

    return await _fetchProfileFromApi();
  }

  /// Invalidate cache (forces next call to fetch from API)
  void invalidateCache() {
    _cachedProfile = null;
    _lastFetched = null;
  }

  /// Check freelancer profile status and return appropriate route
  Future<String?> getRedirectRoute() async {
    final role = await _authStore.getRole();

    if (role != 'freelancer') {
      return null; // Not a freelancer, no redirect needed
    }

    try {
      // Use cached data to avoid unnecessary API calls
      final profile = await _getProfileWithCache();
      if (profile == null) {
        return '/freelancer-form';
      }

      final status = profile['status'] as String?;

      switch (status) {
        case 'approved':
          // Freelancer is approved, can access main feed
          return '/feed';
        case 'pending':
          // Profile is pending admin approval
          return '/success';
        case 'rejected':
          // Profile was rejected, allow editing
          return '/freelancer-form';
        case 'incomplete':
        default:
          // Profile is incomplete, continue onboarding
          return '/freelancer-form';
      }
    } catch (e) {
      // If profile doesn't exist or API fails, continue onboarding
      return '/freelancer-form';
    }
  }

  /// Check if freelancer can access orders feed
  Future<bool> canAccessOrdersFeed() async {
    final role = await _authStore.getRole();

    if (role != 'freelancer') {
      return false;
    }

    try {
      // Use cached data to avoid unnecessary API calls
      final profile = await _getProfileWithCache();
      if (profile == null) {
        return false;
      }
      final status = profile['status'] as String?;
      return status == 'approved';
    } catch (e) {
      return false;
    }
  }

  /// Get current freelancer profile status (uses cache to avoid unnecessary API calls)
  Future<String?> getProfileStatus() async {
    try {
      final profile = await _getProfileWithCache();
      return profile?['status'] as String?;
    } catch (e) {
      return null;
    }
  }

  /// Get current freelancer profile status (always fetches fresh data from API)
  Future<String?> getProfileStatusFresh() async {
    try {
      final profile = await refreshProfile();
      return profile?['status'] as String?;
    } catch (e) {
      return null;
    }
  }
}
