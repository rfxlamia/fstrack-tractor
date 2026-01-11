import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/theme/app_theme.dart';
import 'package:fstrack_tractor/core/theme/app_text_styles.dart';
import 'package:fstrack_tractor/core/theme/app_colors.dart';
import 'package:fstrack_tractor/core/theme/app_spacing.dart';

void main() {
  group('AppTheme', () {
    testWidgets('uses Poppins as default font family', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: Text('Test'),
          ),
        ),
      );

      final BuildContext context = tester.element(find.byType(Scaffold));
      final theme = Theme.of(context);
      expect(theme.textTheme.bodyLarge?.fontFamily, equals('Poppins'));
    });

    test('all 8 Bulldozer text style tokens are defined', () {
      // Verify all tokens exist and have correct properties
      expect(AppTextStyles.w400s8.fontSize, equals(8));
      expect(AppTextStyles.w400s10.fontSize, equals(10));
      expect(AppTextStyles.w400s12.fontSize, equals(12));
      expect(AppTextStyles.w500s10.fontSize, equals(10));
      expect(AppTextStyles.w500s12.fontSize, equals(12));
      expect(AppTextStyles.w600s12.fontSize, equals(12));
      expect(AppTextStyles.w700s13.fontSize, equals(13));
      expect(AppTextStyles.w700s20.fontSize, equals(20));

      // Verify all use Poppins
      expect(AppTextStyles.w400s8.fontFamily, equals('Poppins'));
      expect(AppTextStyles.w700s20.fontFamily, equals('Poppins'));
    });

    test('semantic aliases point to correct Bulldozer tokens', () {
      expect(AppTextStyles.title, equals(AppTextStyles.w700s20));
      expect(AppTextStyles.titleSmall, equals(AppTextStyles.w700s13));
      expect(AppTextStyles.bodyLarge, equals(AppTextStyles.w500s12));
      expect(AppTextStyles.bodyMedium, equals(AppTextStyles.w400s12));
      expect(AppTextStyles.bodySmall, equals(AppTextStyles.w400s10));
      expect(AppTextStyles.caption, equals(AppTextStyles.w400s8));
      expect(AppTextStyles.subtitle, equals(AppTextStyles.w600s12));
      expect(AppTextStyles.headline1, equals(AppTextStyles.w700s20));
      expect(AppTextStyles.headline2, equals(AppTextStyles.w700s13));
    });

    test('AppSpacing constants have correct values', () {
      expect(AppSpacing.xs, equals(8.0));
      expect(AppSpacing.sm, equals(12.0));
      expect(AppSpacing.md, equals(16.0));
      expect(AppSpacing.lg, equals(24.0));
      expect(AppSpacing.xl, equals(32.0));

      expect(AppSpacing.radiusSm, equals(12.0));
      expect(AppSpacing.radiusMd, equals(16.0));
      expect(AppSpacing.radiusLg, equals(20.0));
      expect(AppSpacing.radiusXl, equals(24.0));
      expect(AppSpacing.inputRadius, equals(8.0));

      expect(AppSpacing.buttonHeight, equals(60.0));
      expect(AppSpacing.touchTargetMin, equals(48.0));
    });

    test('AppColors have correct hex values', () {
      // Primary colors
      expect(AppColors.primary, equals(const Color(0xFF008945)));
      expect(AppColors.secondary, equals(const Color(0xFF03DAC6)));
      expect(AppColors.onPrimary, equals(const Color(0xFFFFFFFF)));

      // Background colors
      expect(AppColors.background, equals(const Color(0xFFF5F5F5)));
      expect(AppColors.surface, equals(const Color(0xFFFFFFFF)));

      // Text colors
      expect(AppColors.textPrimary, equals(const Color(0xFF333333)));
      expect(AppColors.textSecondary, equals(const Color(0xFF828282)));

      // Status colors
      expect(AppColors.error, equals(const Color(0xFFB00020)));
      expect(AppColors.success, equals(const Color(0xFF4CAF50)));

      // Button colors
      expect(AppColors.buttonOrange, equals(const Color(0xFFFBA919)));
      expect(AppColors.buttonBlue, equals(const Color(0xFF25AAE1)));

      // Card colors
      expect(AppColors.greyCard, equals(const Color(0xFFF0F0F0)));
      expect(AppColors.greyDate, equals(const Color(0xFF828282)));
    });
  });

  group('AppTextStyles - Font Weights', () {
    test('w400 styles use FontWeight.w400', () {
      expect(AppTextStyles.w400s8.fontWeight, FontWeight.w400);
      expect(AppTextStyles.w400s10.fontWeight, FontWeight.w400);
      expect(AppTextStyles.w400s12.fontWeight, FontWeight.w400);
    });

    test('w500 styles use FontWeight.w500', () {
      expect(AppTextStyles.w500s10.fontWeight, FontWeight.w500);
      expect(AppTextStyles.w500s12.fontWeight, FontWeight.w500);
    });

    test('w600 styles use FontWeight.w600', () {
      expect(AppTextStyles.w600s12.fontWeight, FontWeight.w600);
    });

    test('w700 styles use FontWeight.w700', () {
      expect(AppTextStyles.w700s13.fontWeight, FontWeight.w700);
      expect(AppTextStyles.w700s20.fontWeight, FontWeight.w700);
    });
  });
}
