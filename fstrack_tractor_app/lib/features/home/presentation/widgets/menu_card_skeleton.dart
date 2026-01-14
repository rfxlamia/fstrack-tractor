import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// MenuCardSkeleton Widget - Loading placeholder for MenuCard
///
/// Displays a shimmer loading effect with the same dimensions as MenuCard.
/// Supports both full-width and half-width variants to match actual cards.
///
/// **Usage:**
/// ```dart
/// MenuCardSkeleton(isFullWidth: false)
/// ```
class MenuCardSkeleton extends StatelessWidget {
  /// Whether skeleton should take full width (true) or half width (false)
  final bool isFullWidth;

  const MenuCardSkeleton({
    super.key,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 80.0, // AC2: Same as MenuCard
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm), // 12dp
        ),
        child: Shimmer.fromColors(
          baseColor: AppColors.greyCard,
          highlightColor: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm), // 12dp padding
            child: Row(
              children: [
                // Icon placeholder (circular 40x40)
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.greyCard,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm), // 12dp gap
                // Text placeholders
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title placeholder
                      Container(
                        height: 12,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.greyCard,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Subtitle placeholder
                      Container(
                        height: 10,
                        width: 120,
                        decoration: BoxDecoration(
                          color: AppColors.greyCard,
                          borderRadius: BorderRadius.circular(4),
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
