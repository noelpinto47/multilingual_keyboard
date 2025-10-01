import 'package:flutter/material.dart';

/// Centralized color constants for the multilingual keyboard app
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFF007AFF); // iOS-style blue
  static const Color primaryLight = Color(0xFF87CEEB); // Light blue for single tap
  static const Color primaryVariant = Color(0xFFE0F2FF); // Very light blue

  // Key colors
  static const Color keyBackground = Colors.white;
  static const Color keyBorder = Color.fromARGB(124, 208, 208, 208);
  static const Color specialKeyBorder = Color.fromARGB(125, 249, 249, 249);
  static const Color keyText = Colors.black;
  static const Color specialKeyDefault = Color(0xFFB8B8B8); // Default gray
  
  // Splash and highlight colors
  static const Color keySplash = Colors.grey;
  static const Color keyHighlight = Colors.grey;
  static const Color specialKeySplash = Colors.grey;
  static const Color specialKeyHighlight = Colors.grey;
  
  // Splash and highlight alpha values
  static const double splashAlpha = 0.3;
  static const double highlightAlpha = 0.1;

  // Text colors
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Colors.black87;
  static const Color textOnPrimary = Colors.white; // White text on blue background
  static const Color textOnLight = Colors.black; // Black text on light background
  static const Color textGrey = Color(0xFF888888);
  static const Color textGreyDark = Colors.grey;

  // Background colors
  static const Color keyboardBackground = Color(0xFFE8E8E8); // Light keyboard background
  static const Color modalBackground = Colors.white;
  static const Color pageBackground = Color(0xFFF5F5F5); // Light blue background
  
  // Border colors
  static const Color borderLight = Color.fromARGB(124, 208, 208, 208);

  // Transparent
  static const Color transparent = Colors.transparent;

  // System colors (from Material Design)
  static const Color systemRed = Colors.redAccent;
  static const Color systemWhite = Colors.white;
  static const Color systemGrey = Colors.grey;

  // Helper methods for colors with alpha
  static Color get keySplashWithAlpha => keySplash.withValues(alpha: splashAlpha);
  static Color get keyHighlightWithAlpha => keyHighlight.withValues(alpha: highlightAlpha);
  static Color get specialKeySplashWithAlpha => specialKeySplash.withValues(alpha: splashAlpha);
  static Color get specialKeyHighlightWithAlpha => specialKeyHighlight.withValues(alpha: highlightAlpha);
  static Color get primaryWithLightAlpha => primary.withValues(alpha: 0.1);
  
  // Static methods for border colors that are computed
  static Color get borderGrey => Colors.grey.shade400;

  // Theme-specific colors
  static ColorScheme get lightColorScheme => ColorScheme.fromSeed(seedColor: systemRed);
}