import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../shared/di/service_locator.dart';
import '../../../../shared/storage/preferences_service.dart';
import 'client_onboarding_page_1.dart';
import 'client_onboarding_page_2.dart';

class ClientOnboardingFlowPage extends StatefulWidget {
  const ClientOnboardingFlowPage({super.key, this.returnPath});

  final String? returnPath;

  @override
  State<ClientOnboardingFlowPage> createState() =>
      _ClientOnboardingFlowPageState();
}

class _ClientOnboardingFlowPageState extends State<ClientOnboardingFlowPage> {
  late final PageController _pageController;
  late final PreferencesService _preferencesService;
  int _currentIndex = 0;
  bool _isAnimating = false;
  bool _imagesPreloaded = false;
  bool _hasPreloadedImages = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _preferencesService = sl<PreferencesService>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasPreloadedImages) {
      _hasPreloadedImages = true;
      _preloadImages();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _preloadImages() async {
    if (!mounted) return;

    if (mounted) {
      setState(() => _imagesPreloaded = true);
    }
  }

  Future<void> _handleSkip() async {
    await _preferencesService.setBool(
      AppConstants.clientOnboardingCompletedKey,
      true,
    );
    if (!mounted) return;
    context.go(widget.returnPath ?? AppConstants.myOrdersRoutePath);
  }

  Future<void> _handleComplete() async {
    await _preferencesService.setBool(
      AppConstants.clientOnboardingCompletedKey,
      true,
    );
    if (!mounted) return;
    context.go(widget.returnPath ?? AppConstants.myOrdersRoutePath);
  }

  Future<void> _goToPage(int index) async {
    if (_isAnimating) return;
    _isAnimating = true;
    try {
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      _currentIndex = index;
    } finally {
      _isAnimating = false;
    }
  }

  void _handleNext() {
    if (_currentIndex >= 1) {
      _handleComplete();
      return;
    }
    _goToPage(_currentIndex + 1);
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while preloading images
    if (!_imagesPreloaded) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (index) => _currentIndex = index,
        children: [
          ClientOnboardingPageOne(onNext: _handleNext, onSkip: _handleSkip),
          ClientOnboardingPageTwo(onNext: _handleComplete, onSkip: _handleSkip),
        ],
      ),
    );
  }
}
