import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// MenuCard Widget - Navigation card for HomePage menu options
///
/// Displays a card with an icon, title, subtitle, and optional tap action.
/// Supports both full-width and half-width variants for flexible layouts.
///
/// **Usage:**
/// ```dart
/// MenuCard(
///   icon: Icons.edit_note,
///   title: 'Buat Rencana',
///   subtitle: 'Rencana Kerja Baru',
///   iconBackgroundColor: AppColors.buttonOrange,
///   isFullWidth: false,
///   onTap: () => print('Card tapped'),
/// )
/// ```
class MenuCard extends StatelessWidget {
  /// Icon to display in the card
  final IconData icon;

  /// Main title text
  final String title;

  /// Subtitle text (description)
  final String subtitle;

  /// Background color for the icon container
  final Color? iconBackgroundColor;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Whether card should take full width (true) or half width (false)
  final bool isFullWidth;

  const MenuCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconBackgroundColor,
    this.onTap,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 80.0, // AC1: Minimum height 80dp
      ),
      child: Material(
        color: AppColors.surface,
        elevation: 2.0, // AC1: Elevation shadow
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm), // 12dp
        child: InkWell(
          // AC1: Ripple effect on tap
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm), // 12dp padding
            child: Row(
              children: [
                // Icon container (circular 40x40)
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
                const SizedBox(width: AppSpacing.sm), // 12dp gap
                // Text column
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
}
