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
  Widget buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconBackgroundColor,
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

  group('RoleBasedMenuCards Golden Tests', () {
    testGoldens('Kasie layout (2 cards side-by-side)', (tester) async {
      // Kasie role: 2 cards in Row with 12dp gap
      final widget = Row(
        children: [
          Expanded(
            child: buildMenuCard(
              icon: Icons.edit_note,
              title: 'Buat Rencana',
              subtitle: 'Rencana Kerja Baru',
              iconBackgroundColor: AppColors.buttonOrange,
            ),
          ),
          const SizedBox(width: AppSpacing.sm), // 12dp gap
          Expanded(
            child: buildMenuCard(
              icon: Icons.list_alt,
              title: 'Lihat Rencana',
              subtitle: 'Daftar Rencana Kerja',
              iconBackgroundColor: AppColors.buttonBlue,
            ),
          ),
        ],
      );

      await tester.pumpWidgetBuilder(
        createGoldenWidget(body: widget),
      );

      await screenMatchesGolden(tester, 'role_based_menu_cards_kasie');
    });

    testGoldens('Operator layout (1 full-width card)', (tester) async {
      // Non-Kasie role: 1 full-width card
      final widget = buildMenuCard(
        icon: Icons.list_alt,
        title: 'Lihat Rencana',
        subtitle: 'Daftar Rencana Kerja',
        iconBackgroundColor: AppColors.buttonBlue,
      );

      await tester.pumpWidgetBuilder(
        createGoldenWidget(body: widget),
      );

      await screenMatchesGolden(tester, 'role_based_menu_cards_operator');
    });
  });
}
