import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/work_plan_bloc.dart';
import '../bloc/work_plan_event.dart';
import '../bloc/work_plan_state.dart';

/// Page for displaying the list of work plans
///
/// This is a placeholder implementation for Story 2.1.
/// Full implementation will be done in Story 2.4.
class WorkPlanListPage extends StatelessWidget {
  const WorkPlanListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Rencana Kerja'),
      ),
      body: BlocBuilder<WorkPlanBloc, WorkPlanState>(
        builder: (context, state) {
          if (state is WorkPlanInitial) {
            // Trigger loading on initial state
            context.read<WorkPlanBloc>().add(const LoadWorkPlansRequested());
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WorkPlanLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WorkPlansLoaded) {
            if (state.workPlans.isEmpty) {
              return const Center(
                child: Text('Belum ada rencana kerja'),
              );
            }
            return ListView.builder(
              itemCount: state.workPlans.length,
              itemBuilder: (context, index) {
                final workPlan = state.workPlans[index];
                return ListTile(
                  title: Text('Rencana Kerja ${workPlan.id}'),
                  subtitle: Text(workPlan.statusDisplayText),
                  trailing: Text(workPlan.workDate.toString()),
                );
              },
            );
          }

          if (state is WorkPlanError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<WorkPlanBloc>()
                          .add(const LoadWorkPlansRequested());
                    },
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('State tidak dikenal'));
        },
      ),
    );
  }
}
