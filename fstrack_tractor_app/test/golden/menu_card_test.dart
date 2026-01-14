import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/theme/app_colors.dart';
import 'package:fstrack_tractor/core/theme/app_spacing.dart';
import 'package:fstrack_tractor/core/theme/app_text_styles.dart';
import 'package:fstrack_tractor/core/theme/app_theme.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  Widget createGoldenWidget({required Widget body}) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: body,
        ),
      ),
    );
  }

  /// Replicated MenuCard widget for golden testing
  /// (Following project pattern from weather_widget_test.dart)
  Widget buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconBackgroundColor,
    bool isFullWidth = true,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 80.0,
      ),
      child: Material(
        color: AppColors.surface,
        elevation: 2.0,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ?? AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.onPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.w600s12.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.w400s10.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  group('MenuCard Golden Tests', () {
    testGoldens('MenuCard full-width variant', (tester) async {
      final widget = buildMenuCard(
        icon: Icons.list_alt,
        title: 'Lihat Rencana',
        subtitle: 'Daftar Rencana Kerja',
        iconBackgroundColor: AppColors.buttonBlue,
        isFullWidth: true,
      );

      await tester.pumpWidgetBuilder(
        createGoldenWidget(body: widget),
      );

      await screenMatchesGolden(tester, 'menu_card_full_width');
    });

    testGoldens('MenuCard half-width variant', (tester) async {
      final widget = SizedBox(
        width: 180, // Simulate half-width in typical phone width
        child: buildMenuCard(
          icon: Icons.edit_note,
          title: 'Buat Rencana',
          subtitle: 'Rencana Kerja Baru',
          iconBackgroundColor: AppColors.buttonOrange,
          isFullWidth: false,
        ),
      );

      await tester.pumpWidgetBuilder(
        createGoldenWidget(body: widget),
      );

      await screenMatchesGolden(tester, 'menu_card_half_width');
    });
  });
}
