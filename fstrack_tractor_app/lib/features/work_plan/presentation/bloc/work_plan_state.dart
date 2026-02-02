import 'package:equatable/equatable.dart';

import '../../domain/entities/operator_entity.dart';
import '../../domain/entities/work_plan_entity.dart';

/// Base class for all work plan states
abstract class WorkPlanState extends Equatable {
  const WorkPlanState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class WorkPlanInitial extends WorkPlanState {
  const WorkPlanInitial();
}

/// Loading state
class WorkPlanLoading extends WorkPlanState {
  const WorkPlanLoading();
}

/// State when work plans are loaded successfully
class WorkPlansLoaded extends WorkPlanState {
  final List<WorkPlanEntity> workPlans;
  final WorkPlanEntity? selectedWorkPlan;

  const WorkPlansLoaded({
    required this.workPlans,
    this.selectedWorkPlan,
  });

  @override
  List<Object?> get props => [workPlans, selectedWorkPlan];

  WorkPlansLoaded copyWith({
    List<WorkPlanEntity>? workPlans,
    WorkPlanEntity? selectedWorkPlan,
  }) {
    return WorkPlansLoaded(
      workPlans: workPlans ?? this.workPlans,
      selectedWorkPlan: selectedWorkPlan ?? this.selectedWorkPlan,
    );
  }
}

/// State when a single work plan is loaded
class WorkPlanLoaded extends WorkPlanState {
  final WorkPlanEntity workPlan;

  const WorkPlanLoaded(this.workPlan);

  @override
  List<Object?> get props => [workPlan];
}

/// State when work plan is created successfully
class WorkPlanCreated extends WorkPlanState {
  final WorkPlanEntity workPlan;

  const WorkPlanCreated(this.workPlan);

  @override
  List<Object?> get props => [workPlan];
}

/// State when operator is assigned successfully
class OperatorAssigned extends WorkPlanState {
  final WorkPlanEntity workPlan;

  const OperatorAssigned(this.workPlan);

  @override
  List<Object?> get props => [workPlan];
}

/// State when operators are loaded
class OperatorsLoaded extends WorkPlanState {
  final List<OperatorEntity> operators;
  final OperatorEntity? selectedOperator;

  const OperatorsLoaded({
    required this.operators,
    this.selectedOperator,
  });

  @override
  List<Object?> get props => [operators, selectedOperator];

  OperatorsLoaded copyWith({
    List<OperatorEntity>? operators,
    OperatorEntity? selectedOperator,
  }) {
    return OperatorsLoaded(
      operators: operators ?? this.operators,
      selectedOperator: selectedOperator ?? this.selectedOperator,
    );
  }
}

/// Error state
class WorkPlanError extends WorkPlanState {
  final String message;

  const WorkPlanError(this.message);

  @override
  List<Object?> get props => [message];
}
