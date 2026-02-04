import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/work_plan_bloc.dart';
import '../bloc/work_plan_event.dart';
import '../bloc/work_plan_state.dart';
import '../widgets/create_bottom_sheet.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/work_plan_card.dart';
import '../widgets/work_plan_list_skeleton.dart';

/// Page for displaying the list of work plans
///
/// Features:
/// - AppBar with title "Rencana Kerja"
/// - Skeleton loading shimmer while data loads
/// - WorkPlanCard list when data is loaded
/// - Empty state when no work plans exist
/// - Error state with retry button
/// - FAB for creating new work plans (kasie_pg only)
class WorkPlanListPage extends StatefulWidget {
  const WorkPlanListPage({super.key});

  @override
  State<WorkPlanListPage> createState() => _WorkPlanListPageState();
}

class _WorkPlanListPageState extends State<WorkPlanListPage> {
  @override
  void initState() {
    super.initState();
    // Load work plans when page is first shown
    context.read<WorkPlanBloc>().add(const LoadWorkPlansRequested());
  }

  Future<void> _refreshWorkPlans() async {
    context.read<WorkPlanBloc>().add(const LoadWorkPlansRequested());

    // Wait for the state to update to either success or error
    await context.read<WorkPlanBloc>().stream.firstWhere(
      (state) => state is WorkPlansLoaded || state is WorkPlanError,
    );
  }

  void _showCreateBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<WorkPlanBloc>(),
        child: const CreateBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Rencana Kerja',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: BlocBuilder<WorkPlanBloc, WorkPlanState>(
        builder: (context, state) {
          return switch (state) {
            WorkPlanInitial() => const WorkPlanListSkeleton(),
            WorkPlanLoading() => const WorkPlanListSkeleton(),
            WorkPlansLoaded(workPlans: final workPlans) =>
              workPlans.isEmpty
                ? EmptyStateWidget(onCreateTap: _showCreateBottomSheet)
                : RefreshIndicator(
                    onRefresh: _refreshWorkPlans,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: workPlans.length,
                      itemBuilder: (context, index) {
                        final workPlan = workPlans[index];
                        return WorkPlanCard(
                          workPlan: workPlan,
                          onTap: () => _showDetailPlaceholder(),
                        );
                      },
                    ),
                  ),
            WorkPlanError(message: final message) => _ErrorWidget(
                message: message,
                onRetry: () {
                  context
                      .read<WorkPlanBloc>()
                      .add(const LoadWorkPlansRequested());
                },
              ),
            _ => const SizedBox.shrink(),
          };
        },
      ),
      floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          // RBAC: Only show FAB for kasie_pg role
          if (state is! AuthSuccess ||
              state.user.role != UserRole.kasiePg) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton(
            onPressed: _showCreateBottomSheet,
            backgroundColor: AppColors.buttonOrange,
            child: const Icon(Icons.add, color: Colors.white),
          );
        },
      ),
    );
  }

  void _showDetailPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Detail view akan tersedia di Epic 4'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Error widget with retry button
class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
