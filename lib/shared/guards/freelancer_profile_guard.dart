import '../services/freelancer_profile_status_manager.dart';
import '../state/auth.dart';

/// Guard to check freelancer profile status before allowing access
class FreelancerProfileGuard {
  final FreelancerProfileStatusManager _statusManager;
  final AuthStore _authStore;

  FreelancerProfileGuard(this._statusManager, this._authStore);

  /// Check if freelancer can access order flow
  Future<bool> canAccessOrderFlow() async {
    final role = await _authStore.getRole();

    // Non-freelancers can access (clients)
    if (role != 'freelancer') {
      return true;
    }

    // Check freelancer status
    try {
      final status = await _statusManager.getProfileStatus();
      return status == 'approved';
    } catch (e) {
      // If error getting status, deny access to be safe
      return false;
    }
  }

  /// Get redirect route for freelancer based on status
  Future<String?> getRequiredRedirect() async {
    final role = await _authStore.getRole();

    // Only apply to freelancers
    if (role != 'freelancer') {
      return null;
    }

    try {
      final status = await _statusManager.getProfileStatus();

      switch (status) {
        case 'pending':
          return '/success';
        case 'rejected':
        case 'incomplete':
          return '/freelancer-form';
        case 'approved':
          return null; // No redirect needed
        default:
          return '/freelancer-form';
      }
    } catch (e) {
      // If error, redirect to form to be safe
      return '/freelancer-form';
    }
  }
}
