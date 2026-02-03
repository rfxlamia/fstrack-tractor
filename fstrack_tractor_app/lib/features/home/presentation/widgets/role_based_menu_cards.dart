import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/ui_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../work_plan/presentation/bloc/work_plan_bloc.dart';
import '../../../work_plan/presentation/bloc/work_plan_event.dart';
import '../../../work_plan/presentation/pages/work_plan_list_page.dart';
import 'coming_soon_bottom_sheet.dart';
import 'menu_card.dart';
import 'menu_card_skeleton.dart';

/// RoleBasedMenuCards - Displays menu cards based on user role
///
/// For Kasie: Shows 2 cards side-by-side (Buat Rencana + Lihat Rencana)
/// For others: Shows 1 full-width card (Lihat Rencana only)
///
/// Handles loading state with skeleton placeholders.
class RoleBasedMenuCards extends StatelessWidget {
  /// GlobalKey for the "Lihat Rencana Kerja" MenuCard (for tooltip positioning)
  final GlobalKey? viewMenuCardKey;

  const RoleBasedMenuCards({super.key, this.viewMenuCardKey});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // AC10: Show skeleton if not authenticated yet
        if (state is! AuthSuccess) {
          return _buildSkeletonLoading();
        }

        final user = state.user;
        final isKasie = user.role.isKasieType;

        // AC3: Kasie layout (2 cards in Row) - both PG and FE variants
        if (isKasie) {
          return _buildKasieLayout(context);
        }

        // AC3: Non-Kasie layout (1 full-width card)
        return _buildNonKasieLayout(context);
      },
    );
  }

  /// Skeleton loading for edge case when AuthBloc state is not ready
  Widget _buildSkeletonLoading() {
    return const Row(
      children: [
        Expanded(child: MenuCardSkeleton(isFullWidth: false)),
        SizedBox(width: AppSpacing.sm),
        Expanded(child: MenuCardSkeleton(isFullWidth: false)),
      ],
    );
  }

  /// Kasie layout: 2 cards side-by-side
  Widget _buildKasieLayout(BuildContext context) {
    return Row(
      children: [
        // Card 1: "Buat Rencana Kerja" (AC4)
        Expanded(
          child: MenuCard(
            isFullWidth: false,
            icon: Icons.edit_note, // or Icons.add_task
            iconBackgroundColor: AppColors.buttonOrange,
            title: UIStrings.menuCardCreateTitle,
            subtitle: UIStrings.menuCardCreateSubtitle,
            onTap: () => ComingSoonBottomSheet.show(
              context,
              UIStrings.menuCardCreateTitle,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm), // 12dp gap
        // Card 2: "Lihat Rencana Kerja" (AC4)
        Expanded(
          child: MenuCard(
            key: viewMenuCardKey,
            isFullWidth: false,
            icon: Icons.list_alt, // or Icons.assignment
            iconBackgroundColor: AppColors.buttonBlue,
            title: UIStrings.menuCardViewTitle,
            subtitle: UIStrings.menuCardViewSubtitle,
            onTap: () => _navigateToWorkPlanList(context),
          ),
        ),
      ],
    );
  }

  /// Non-Kasie layout: 1 full-width card
  Widget _buildNonKasieLayout(BuildContext context) {
    return MenuCard(
      key: viewMenuCardKey,
      isFullWidth: true,
      icon: Icons.list_alt,
      iconBackgroundColor: AppColors.buttonBlue,
      title: UIStrings.menuCardViewTitle,
      subtitle: UIStrings.menuCardViewSubtitle,
      onTap: () => _navigateToWorkPlanList(context),
    );
  }

  /// Navigate to WorkPlanListPage with BLoC provided
  void _navigateToWorkPlanList(BuildContext context) {
    // Trigger loading work plans
    context.read<WorkPlanBloc>().add(const LoadWorkPlansRequested());

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: context.read<WorkPlanBloc>(),
          child: const WorkPlanListPage(),
        ),
      ),
    );
  }
}
