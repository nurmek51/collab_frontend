import '../storage/preferences_service.dart';
import '../state/auth.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/api_service.dart';

class ClientGuard {
  final PreferencesService _preferencesService;
  final AuthStore _authStore;
  final ApiService _apiService;

  ClientGuard(this._preferencesService, this._authStore, this._apiService);

  Future<String?> getRequiredRedirect() async {
    final role = await _authStore.getRole();

    if (role != 'client') {
      return null;
    }

    final isOnboardingCompleted =
        await _preferencesService.getBool(
          AppConstants.clientOnboardingCompletedKey,
        ) ??
        false;

    if (isOnboardingCompleted) {
      return null;
    }

    try {
      final orders = await _apiService.getMyOrders();

      if (orders.isNotEmpty) {
        await _preferencesService.setBool(
          AppConstants.clientOnboardingCompletedKey,
          true,
        );
        return null;
      }
    } catch (e) {
      // If error fetching orders, show onboarding to be safe
    }

    return AppConstants.clientOnboardingRoutePath;
  }

  Future<bool> shouldShowOnboarding() async {
    final role = await _authStore.getRole();

    if (role != 'client') {
      return false;
    }

    final redirectRoute = await getRequiredRedirect();
    return redirectRoute == AppConstants.clientOnboardingRoutePath;
  }
}
