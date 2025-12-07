import 'package:flutter/material.dart';

/// App color constants extracted from Figma design
class AppColors {
  AppColors._();

  // Primary colors from Figma
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  static const Color backgroundColor = Color(0xFFE8F0F1);

  // Button colors
  static const Color buttonBackground = black;
  static const Color buttonText = white;

  // Text colors
  static const Color primaryText = Color(0xFF353F49); // #353F49 from Figma
  static const Color secondaryText = black;
  static const Color stepNumberColor = Color(0xFF85CBD9); // #85CBD9 from Figma
  static const Color profileIconColor = Color(0xFF517499); // #517499 from Figma
  static const Color inputLabelColor = Color(0xFFBCC5C7); // #BCC5C7 from Figma
  static const Color inputBorderColor = Color(0xFFCADDE1); // #CADDE1 from Figma
  static const Color linkColor = Color(0xFF517499); // #517499 from Figma
  static const Color blueAccent = Color(0xFF2782E3); // #2782E3 from Figma
  static const Color lightGrayBackground = Color(
    0xFFF5F7F9,
  ); // #F5F7F9 from Figma
  static const Color orangeAccent = Color(0xFFF4AA6A); // #F4AA6A from Figma
  static const Color adminBackground = Color(0xFFF3F4F6);
  static const Color adminSidebar = Color(0xFFF7F8FA);
  static const Color adminDivider = Color(0xFFE5E7EB);
  static const Color adminPrimaryText = Color(0xFF1F2937);
  static const Color adminSecondaryText = Color(0xFF6B7280);
  static const Color adminAccentBlue = Color(0xFF2563EB);
  static const Color adminAccentGreen = Color(0xFF22C55E);
  static const Color adminAccentOrange = Color(0xFFF97316);
  static const Color adminCardBackground = Color(0xFFFFFFFF);
  static const Color adminBadgeNeutral = Color(0xFFD1D5DB);

  // Indicator colors (for page indicators)
  static const Color activeIndicator = black;
  static const Color inactiveIndicator = Color(
    0x33000000,
  ); // black with 20% opacity
}
