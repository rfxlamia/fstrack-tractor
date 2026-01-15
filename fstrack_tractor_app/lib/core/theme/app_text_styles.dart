import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract class AppTextStyles {
  // Private font family constant for Poppins
  static const String _fontFamily = 'Poppins';

  // ==========================================
  // FULL Bulldozer Token Set (AC4)
  // ==========================================

  // w400s8 - Micro text (8px, weight 400)
  static const TextStyle w400s8 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 8,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // w400s10 - Caption (10px, weight 400)
  static const TextStyle w400s10 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // w400s12 - Body small (12px, weight 400)
  static const TextStyle w400s12 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // w500s10 - Caption emphasized (10px, weight 500)
  static const TextStyle w500s10 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // w500s12 - Body (12px, weight 500)
  static const TextStyle w500s12 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // w600s12 - Subtitle (12px, weight 600)
  static const TextStyle w600s12 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // w700s13 - Title small (13px, weight 700)
  static const TextStyle w700s13 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // w700s20 - Title/Header (20px, weight 700)
  static const TextStyle w700s20 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // ==========================================
  // UX Spec Alignment - TD-004 Fix (2026-01-15)
  // Per ux-final-direction.html specifications
  // ==========================================

  // w400s11 - Weather time (11px, weight 400)
  static const TextStyle w400s11 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // w400s13 - Weather condition, Card date (13px, weight 400)
  static const TextStyle w400s13 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // w500s13 - Weather condition emphasized (13px, weight 500)
  static const TextStyle w500s13 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // w500s16 - Greeting (16px, weight 500)
  static const TextStyle w500s16 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // w600s14 - Section title (14px, weight 600)
  static const TextStyle w600s14 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // w700s18 - Card location (18px, weight 700)
  static const TextStyle w700s18 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // w700s24 - Weather temperature (24px, weight 700)
  static const TextStyle w700s24 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // ==========================================
  // Semantic Aliases for Backward Compatibility (AC4)
  // ==========================================

  // Headlines
  static const TextStyle headline1 = w700s20;
  static const TextStyle headline2 = w700s13;
  static const TextStyle headline3 = w600s12;

  // Body
  static const TextStyle bodyLarge = w500s12;
  static const TextStyle bodyMedium = w400s12;
  static const TextStyle bodySmall = w400s10;

  // Caption
  static const TextStyle caption = w400s8;
  static const TextStyle captionMedium = w500s10;

  // Title
  static const TextStyle title = w700s20;
  static const TextStyle titleSmall = w700s13;

  // Subtitle
  static const TextStyle subtitle = w600s12;

  // ==========================================
  // Legacy Styles (for backward compatibility)
  // ==========================================

  static const headlineLarge = headline1;
  static const headlineMedium = headline2;
  static const headlineSmall = headline3;
  static const labelLarge = buttonLarge;
  static const labelMedium = buttonMedium;

  // ==========================================
  // Button Styles
  // ==========================================

  static const buttonLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
  );

  static const buttonMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.onPrimary,
  );
}
