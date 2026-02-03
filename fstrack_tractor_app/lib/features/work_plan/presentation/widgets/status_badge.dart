import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/work_plan_entity.dart';

/// Badge widget for displaying work plan status
///
/// Uses WorkPlanEntity.statusDisplayText getter for Indonesian text
/// with color-coded backgrounds based on status.
///
/// Usage:
/// ```dart
/// StatusBadge(workPlan: workPlanEntity)  // Shows "Terbuka" with orange background
/// ```
class StatusBadge extends StatelessWidget {
  final WorkPlanEntity workPlan;

  const StatusBadge({super.key, required this.workPlan});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _getStatusColor(workPlan.status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        workPlan.statusDisplayText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    return switch (status) {
      'OPEN' => AppColors.buttonOrange,
      'CLOSED' => AppColors.buttonBlue,
      'CANCEL' => AppColors.error,
      _ => AppColors.textSecondary,
    };
  }
}
