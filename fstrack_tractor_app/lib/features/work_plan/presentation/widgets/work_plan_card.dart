import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/work_plan_entity.dart';

/// Card widget for displaying a work plan
///
/// This is a placeholder implementation for Story 2.1.
/// Full implementation with proper styling will be done in Story 2.4.
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
    return Card(
      color: AppColors.surface,
      child: ListTile(
        onTap: onTap,
        title: Text(
          'Rencana Kerja',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tanggal: ${_formatDate(workPlan.workDate)}'),
            Text('Pola: ${workPlan.pattern}'),
            Text('Shift: ${workPlan.shift}'),
          ],
        ),
        trailing: StatusBadge(status: workPlan.status),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Badge widget for displaying work plan status
///
/// Maps backend status values to user-friendly Indonesian text.
class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, text) = _getStatusStyle(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, String) _getStatusStyle(String status) {
    switch (status) {
      case 'OPEN':
        return (AppColors.buttonBlue, 'Terbuka');
      case 'CLOSED':
        return (AppColors.success, 'Ditugaskan');
      case 'CANCEL':
        return (AppColors.error, 'Dibatalkan');
      default:
        return (AppColors.textSecondary, status);
    }
  }
}
