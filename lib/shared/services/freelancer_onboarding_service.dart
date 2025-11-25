import '../api/freelancer_api.dart';
import '../state/freelancer_onboarding_state.dart';
import '../di/service_locator.dart';
import 'freelancer_profile_status_manager.dart';

/// Centralized service for managing freelancer onboarding flow
/// Eliminates duplicate API calls and manages state consistently
class FreelancerOnboardingService {
  // Cache to prevent duplicate API calls
  FreelancerOnboardingState? _cachedProfileState;
  bool _isProfileLoaded = false;

  FreelancerOnboardingService();

  FreelancerApi get _freelancerApi => sl<FreelancerApi>();
  FreelancerOnboardingStore get _onboardingStore =>
      sl<FreelancerOnboardingStore>();

  /// Load state for a page - handles both onboarding and edit modes
  /// Returns cached data if already loaded to prevent duplicate API calls
  Future<FreelancerOnboardingLoadResult> loadPageState({
    bool isFromSuccessPage = false,
  }) async {
    // Load current accumulated state
    var currentState = await _onboardingStore.loadState();

    // Determine if we're in edit mode
    // Edit mode is true if:
    // 1. Explicitly coming from success page (edit data button)
    // 2. User has a profile already
    final isEditMode = isFromSuccessPage || currentState.hasProfile;

    // Only fetch from API if:
    // 1. We're in edit mode
    // 2. We haven't already loaded the profile data
    // 3. We don't have a cached profile state
    if (isEditMode && !_isProfileLoaded && _cachedProfileState == null) {
      try {
        final profile = await _freelancerApi.getProfile();
        if (profile.isNotEmpty) {
          _cachedProfileState = FreelancerOnboardingState.fromApi(profile);
          await _onboardingStore.saveState(_cachedProfileState!);
          currentState = _cachedProfileState!;
          _isProfileLoaded = true;
        }
      } catch (_) {
        // If API fails, use stored state
      }
    } else if (_cachedProfileState != null) {
      // Use cached profile state if available
      currentState = _cachedProfileState!;
    }

    return FreelancerOnboardingLoadResult(
      state: currentState,
      isEditMode: isEditMode,
    );
  }

  /// Update state and persist to storage
  Future<void> updateState(FreelancerOnboardingState newState) async {
    await _onboardingStore.saveState(newState);

    // Update cache if we're in edit mode
    if (newState.hasProfile) {
      _cachedProfileState = newState;
    }
  }

  /// Submit profile data (create or update)
  Future<void> submitProfile(FreelancerOnboardingState state) async {
    if (state.hasProfile) {
      await _freelancerApi.updateProfile(state);
    } else {
      await _freelancerApi.createProfile(state);
      final updatedState = state.copyWith(hasProfile: true);
      await updateState(updatedState);
      await _onboardingStore.updateField('hasProfile', true);
    }

    // Invalidate profile status cache when profile data changes
    final statusManager = sl<FreelancerProfileStatusManager>();
    statusManager.invalidateCache();
  }

  /// Clear all cached data and stored state - useful for logout or starting fresh
  Future<void> clearState() async {
    await _onboardingStore.clearState();
    clearCache();
  }

  /// Clear all cached data - useful for logout or starting fresh
  void clearCache() {
    _cachedProfileState = null;
    _isProfileLoaded = false;
  }

  /// Get current accumulated state without API calls
  Future<FreelancerOnboardingState> getCurrentState() async {
    return await _onboardingStore.loadState();
  }
}

/// Result class for loading page state
class FreelancerOnboardingLoadResult {
  final FreelancerOnboardingState state;
  final bool isEditMode;

  const FreelancerOnboardingLoadResult({
    required this.state,
    required this.isEditMode,
  });
}
