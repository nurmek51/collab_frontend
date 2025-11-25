import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../shared/api/auth_api.dart';
import '../../shared/state/freelancer_onboarding_state.dart';
import '../../shared/di/service_locator.dart';

/// Global debug overlay that provides auth cache clearing functionality
class DebugOverlay extends StatefulWidget {
  final Widget child;

  const DebugOverlay({super.key, required this.child});

  @override
  State<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends State<DebugOverlay> {
  AuthApi? _authApi;
  FreelancerOnboardingStore? _onboardingStore;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      _authApi = sl<AuthApi>();
      _onboardingStore = sl<FreelancerOnboardingStore>();
    } catch (e) {
      // Services might not be initialized yet, will retry in didChangeDependencies
    }
  }

  Future<void> _clearAuthCache() async {
    if (_authApi == null || _onboardingStore == null) {
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Services not initialized yet'),
        //     backgroundColor: Colors.orange,
        //   ),
        // );
      }
      return;
    }

    try {
      await _authApi!.logout();
      await _onboardingStore!.clearState();
      if (mounted) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Auth cache cleared successfully'),
        //     backgroundColor: Colors.green,
        //   ),
        // );
        // Navigate back to login
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear auth cache: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_authApi == null || _onboardingStore == null) {
      _initializeServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Only show debug button if services are initialized
        if (_authApi != null && _onboardingStore != null)
          Positioned(
            top: 50.h, // Below status bar
            right: 20.w,
            child: GestureDetector(
              onTap: _clearAuthCache,
              child: Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(255, 0, 0, 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.clear, color: Colors.white, size: 20),
              ),
            ),
          ),
      ],
    );
  }
}
