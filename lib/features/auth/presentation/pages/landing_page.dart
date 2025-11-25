import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/state/auth.dart';
import '../../../../shared/services/freelancer_profile_status_manager.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../../core/widgets/loading_states.dart';
import '../../../../core/animations/animations.dart';

/// Landing page that redirects users based on their auth state and profile status
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkUserStateAndRedirect();
    });
  }

  Future<void> _checkUserStateAndRedirect() async {
    final authStore = sl<AuthStore>();
    final statusManager = sl<FreelancerProfileStatusManager>();

    // Check if user is authenticated
    final isAuthenticated = await authStore.isAuthenticated();

    if (!isAuthenticated) {
      // Not authenticated, go to welcome page
      if (mounted) {
        context.go('/welcome');
      }
      return;
    }

    // User is authenticated, check role
    final role = await authStore.getRole();

    switch (role) {
      case 'client':
        // Client routing is now handled by AppRouter's redirect logic
        if (mounted) {
          context.go('/my-orders');
        }
        break;

      case 'freelancer':
        // Check freelancer profile status
        final redirectRoute = await statusManager.getRedirectRoute();
        if (mounted && redirectRoute != null) {
          try {
            context.go(redirectRoute);
          } catch (e) {
            // Fallback navigation
            context.pushReplacement(redirectRoute);
          }
        }
        break;

      default:
        // No role or unknown role, go to role selection
        if (mounted) {
          context.go('/select-role');
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeInAnimation(
        duration: AnimationConstants.medium,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleInAnimation(
                delay: const Duration(milliseconds: 200),
                child: const AnimatedLoadingSpinner(
                  size: 40,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              SlideInAnimation(
                begin: const Offset(0, 0.5),
                delay: const Duration(milliseconds: 400),
                child: Text(
                  'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
