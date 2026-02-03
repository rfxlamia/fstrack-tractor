import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/work_plan_entity.dart';
import 'status_badge.dart';

/// Card widget for displaying a work plan
///
/// Displays work plan information with:
/// - Colored left border based on status (OPEN=orange, CLOSED=blue)
/// - Formatted date, pattern, shift, and location ID
/// - Status badge with appropriate colors
///
/// Usage:
/// ```dart
/// WorkPlanCard(
///   workPlan: workPlanEntity,
///   onTap: () => navigateToDetail(workPlanEntity),
/// )
/// ```
class WorkPlanCard extends StatelessWidget {
  final WorkPlanEntity workPlan;
  final VoidCallback? onTap;

  const WorkPlanCard({
    super.key,
    required this.workPlan,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = _getBorderColor(workPlan.status);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 4,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Status row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date
                    Expanded(
                      child: Text(
                        formatWorkDate(workPlan.workDate),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Status badge
                    StatusBadge(workPlan: workPlan),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                // Pattern and Shift
                Text(
                  '${workPlan.pattern} - ${workPlan.shift}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                // Location ID
                Text(
                  workPlan.locationId,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    fontFamily: 'Poppins',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getBorderColor(String status) {
    return switch (status) {
      'OPEN' => AppColors.buttonOrange,
      'CLOSED' => AppColors.buttonBlue,
      'CANCEL' => AppColors.error,
      _ => AppColors.greyCard,
    };
  }
}
