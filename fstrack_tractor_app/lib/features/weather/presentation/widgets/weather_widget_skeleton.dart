import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Skeleton loader for WeatherWidget
///
/// Shows shimmer placeholder while weather data loads.
class WeatherWidgetSkeleton extends StatelessWidget {
  const WeatherWidgetSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.greyCard,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Temperature placeholder
            Container(
              width: 80,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.greyCard,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Condition placeholder
            Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.greyCard,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Icon and location row placeholder
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.greyCard,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  width: 100,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.greyCard,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Timestamp placeholder
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 80,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.greyCard,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
