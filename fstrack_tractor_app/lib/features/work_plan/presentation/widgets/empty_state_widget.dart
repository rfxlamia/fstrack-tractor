import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Empty state widget for work plan list
///
/// Displayed when no work plans exist in the database.
/// Shows a message prompting the user to create their first work plan.
///
/// Usage:
/// ```dart
/// EmptyStateWidget(
///   onCreateTap: () => showCreateBottomSheet(),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  final VoidCallback? onCreateTap;

  const EmptyStateWidget({
    super.key,
    this.onCreateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: AppColors.textSecondary.withAlpha(128),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Title
            const Text(
              'Belum ada rencana kerja',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Subtitle message
            const Text(
              'Tap + untuk membuat.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
                fontFamily: 'Poppins',
              ),
            ),
            if (onCreateTap != null) ...[
              const SizedBox(height: AppSpacing.lg),
              // Create button
              ElevatedButton.icon(
                onPressed: onCreateTap,
                icon: const Icon(Icons.add),
                label: const Text('Buat Rencana Kerja'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
