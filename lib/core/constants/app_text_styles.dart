import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Text styles extracted from Figma design
class AppTextStyles {
  AppTextStyles._();

  // Button text style from Figma
  static TextStyle get buttonText => TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w500,
    fontSize: 17.0,
    height: 1.2,
    leadingDistribution: TextLeadingDistribution.even,
    color: Colors.white,
  );

  // Heading text style from Figma
  static TextStyle get heading => TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w400,
    fontSize: 17.0,
    height: 1.3, // lineHeight: 1.2999999102424173em from Figma
    color: Colors.black,
  );

  // Body text styles
  static TextStyle get bodyMedium => TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    height: 1.3,
    color: Colors.black,
  );

  static TextStyle get bodySmall => TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w400,
    fontSize: 14.0,
    height: 1.3,
    color: Colors.black,
  );

  // My Orders page specific styles from Figma
  static TextStyle get pageTitle => TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w700,
    fontSize: 26.0,
    height: 1.149, // lineHeight: 1.1490000211275542em from Figma
    color: const Color(0xFF353F49),
  );

  static TextStyle get emptyStateTitle => TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
    height: 1.3, // lineHeight: 1.2999999523162842em from Figma
    color: const Color(0xFF353F49),
  );

  static TextStyle get stepText => TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    height: 1.3, // lineHeight: 1.2999999523162842em from Figma
    color: const Color(0xFF353F49),
  );

  static TextStyle get sectionTitle => TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
    height: 1.3, // lineHeight: 1.2999999523162842em from Figma
    color: Colors.black,
  );

  static TextStyle get footerText => TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    height: 1.3, // lineHeight: 1.2999999523162842em from Figma
    color: Colors.black,
  );

  static TextStyle get stepNumber => TextStyle(
    fontFamily: 'SF Compact',
    fontWeight: FontWeight.w500, // Closest available weight to w457
    fontSize: 28.0,
    height: 1.0, // lineHeight: 1em from Figma
    color: const Color(0xFF85CBD9),
  );

  static TextStyle get profileIcon => TextStyle(
    fontFamily: 'SF Compact',
    fontWeight: FontWeight.w500, // Closest available weight to w457
    fontSize: 26.0,
    height: 1.193, // lineHeight: 1.193359375em from Figma
    color: const Color(0xFF517499),
  );

  // New Order page specific styles from Figma
  static TextStyle get backIcon => TextStyle(
    fontFamily: 'SF Compact',
    fontWeight: FontWeight.w600, // Closest to w656 from Figma
    fontSize: 26.0,
    height: 1.193, // lineHeight: 1.193359375em from Figma
    color: const Color(0xFF353F49),
  );

  static TextStyle get inputLabel => TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w400,
    fontSize: 17.0,
    height: 1.149, // lineHeight: 1.1490000556497013em from Figma
    color: const Color(0xFFBCC5C7),
  );

  static TextStyle get textAreaPlaceholder => TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w400,
    fontSize: 17.0,
    height: 1.3, // lineHeight: 1.2999999102424173em from Figma
    color: const Color(0xFFBCC5C7),
  );

  static TextStyle get linkText => TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    height: 1.3, // lineHeight: 1.2999999523162842em from Figma
    color: const Color(0xFF517499),
  );

  // Order states specific styles from Figma
  static TextStyle get orderCreatedTitle => TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w700,
    fontSize: 21.0,
    height: 1.149, // lineHeight: 1.1490000770205544em from Figma
    color: const Color(0xFF353F49),
  );

  static TextStyle get orderCreatedDescription => TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    height: 1.3, // lineHeight: 1.2999999523162842em from Figma
    color: const Color(0xFF353F49),
  );

  static TextStyle get projectTitle => TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w700,
    fontSize: 21.0,
    height: 1.149, // lineHeight: 1.1490000770205544em from Figma
    color: Colors.black,
  );

  static TextStyle get projectActionText => TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    height: 1.3, // lineHeight: 1.2999999523162842em from Figma
    color: const Color(0xFF517499),
  );

  static TextStyle get addOrderText => TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w500,
    fontSize: 16.0,
    height: 1.3, // lineHeight: 1.2999999523162842em from Figma
    color: const Color(0xFF517499),
  );

  static const TextStyle _onboardingHeadlineBase = TextStyle(
    fontFamily: 'Ubuntu',
    fontSize: 32.0,
    height: 1.149,
    color: AppColors.black,
  );

  static TextStyle get onboardingHeadline =>
      _onboardingHeadlineBase.copyWith(fontWeight: FontWeight.w700);

  static TextStyle get onboardingHeadlineRegular =>
      _onboardingHeadlineBase.copyWith(fontWeight: FontWeight.w400);

  static TextStyle get onboardingHeadlineEmphasis =>
      onboardingHeadlineRegular.copyWith(fontWeight: FontWeight.w700);

  static TextStyle get onboardingHeadlineLarge =>
      onboardingHeadline.copyWith(fontSize: 33.25);

  static TextStyle get onboardingBody => const TextStyle(
    fontFamily: 'Ubuntu',
    fontWeight: FontWeight.w400,
    fontSize: 16.0,
    height: 1.3,
    color: AppColors.primaryText,
  );
}
