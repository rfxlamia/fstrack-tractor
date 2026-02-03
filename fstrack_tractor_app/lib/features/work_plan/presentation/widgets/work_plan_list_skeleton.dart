import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Skeleton loader for work plan list
///
/// Shows native Flutter shimmer animation with placeholder cards.
/// Displays 4 placeholder cards that mimic the actual WorkPlanCard layout.
///
/// Pattern reference: weather_skeleton.dart (native animation, no external packages)
///
/// Usage:
/// ```dart
/// WorkPlanListSkeleton()
/// ```
class WorkPlanListSkeleton extends StatefulWidget {
  const WorkPlanListSkeleton({super.key});

  @override
  State<WorkPlanListSkeleton> createState() => _WorkPlanListSkeletonState();
}

class _WorkPlanListSkeletonState extends State<WorkPlanListSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      itemCount: 4,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Opacity(
              opacity: _animation.value,
              child: _SkeletonCard(),
            );
          },
        );
      },
    );
  }
}

/// Individual skeleton card that mimics WorkPlanCard layout
class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(
            color: AppColors.greyCard,
            width: 4,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date and Status row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date placeholder
              Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.greyCard,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Status badge placeholder
              Container(
                width: 70,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.greyCard,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Pattern and Shift placeholder
          Container(
            width: 150,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.greyCard,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Location placeholder
          Container(
            width: 80,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.greyCard,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
