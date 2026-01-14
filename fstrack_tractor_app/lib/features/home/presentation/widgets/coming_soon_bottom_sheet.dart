import 'package:flutter/material.dart';

import '../../../../core/constants/ui_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// ComingSoonBottomSheet - MVP placeholder for unimplemented features
///
/// Displays a bottom sheet informing users that a feature is under development.
/// Used for menu card taps and FAB taps in MVP phase.
///
/// **Usage:**
/// ```dart
/// ComingSoonBottomSheet.show(context, 'Buat Rencana Kerja');
/// ```
class ComingSoonBottomSheet extends StatelessWidget {
  /// Feature name to display in the subtitle
  final String featureName;

  const ComingSoonBottomSheet({
    super.key,
    required this.featureName,
  });

  /// Static method to show the bottom sheet
  ///
  /// [context] - BuildContext for showModalBottomSheet
  /// [featureName] - Name of the feature that's coming soon
  static void show(BuildContext context, String featureName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusMd), // 16dp
        ),
      ),
      isDismissible: true, // AC5: Dismissible via swipe down or tap outside
      enableDrag: true,
      builder: (context) => ComingSoonBottomSheet(featureName: featureName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg), // 24dp padding
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon: Icons.construction, size: 64, color: textSecondary
          const Icon(
            Icons.construction,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md), // 16dp gap

          // Title: "Fitur Segera Hadir", w700s20
          const Text(
            UIStrings.comingSoonTitle,
            style: AppTextStyles.w700s20,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs), // 8dp gap

          // Subtitle: "Fitur {featureName} sedang dalam pengembangan", w400s12
          Text(
            'Fitur $featureName ${UIStrings.comingSoonSubtitle}',
            style: AppTextStyles.w400s12.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg), // 24dp gap

          // Button: "Tutup", primary color, calls Navigator.pop
          SizedBox(
            width: double.infinity,
            height: AppSpacing.buttonHeight, // 60dp
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: const Text(
                UIStrings.comingSoonClose,
                style: AppTextStyles.buttonLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
