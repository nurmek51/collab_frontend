import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class OnboardingWrapper extends StatelessWidget {
  const OnboardingWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(color: AppColors.backgroundColor),
      child: SafeArea(
        top: true,
        bottom: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: child,
        ),
      ),
    );
  }
}
