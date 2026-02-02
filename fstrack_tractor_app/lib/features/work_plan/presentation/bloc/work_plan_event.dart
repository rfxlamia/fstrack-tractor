import 'package:equatable/equatable.dart';

import '../../domain/entities/operator_entity.dart';
import '../../domain/entities/work_plan_entity.dart';

/// Base class for all work plan events
abstract class WorkPlanEvent extends Equatable {
  const WorkPlanEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all work plans
class LoadWorkPlansRequested extends WorkPlanEvent {
  const LoadWorkPlansRequested();
}

/// Event to load a specific work plan by ID
class LoadWorkPlanByIdRequested extends WorkPlanEvent {
  final String workPlanId;

  const LoadWorkPlanByIdRequested(this.workPlanId);

  @override
  List<Object?> get props => [workPlanId];
}

/// Event to create a new work plan
class CreateWorkPlanRequested extends WorkPlanEvent {
  final DateTime workDate;
  final String pattern;
  final String shift;
  final String locationId;
  final String unitId;
  final String? notes;

  const CreateWorkPlanRequested({
    required this.workDate,
    required this.pattern,
    required this.shift,
    required this.locationId,
    required this.unitId,
    this.notes,
  });

  @override
  List<Object?> get props => [
        workDate,
        pattern,
        shift,
        locationId,
        unitId,
        notes,
      ];
}

/// Event to assign an operator to a work plan
class AssignOperatorRequested extends WorkPlanEvent {
  final String workPlanId;
  final int operatorId;

  const AssignOperatorRequested({
    required this.workPlanId,
    required this.operatorId,
  });

  @override
  List<Object?> get props => [workPlanId, operatorId];
}

/// Event to load all operators
class LoadOperatorsRequested extends WorkPlanEvent {
  const LoadOperatorsRequested();
}

/// Event when work plan selection changes
class WorkPlanSelected extends WorkPlanEvent {
  final WorkPlanEntity? workPlan;

  const WorkPlanSelected(this.workPlan);

  @override
  List<Object?> get props => [workPlan];
}

/// Event when operator selection changes
class OperatorSelected extends WorkPlanEvent {
  final OperatorEntity? operator;

  const OperatorSelected(this.operator);

  @override
  List<Object?> get props => [operator];
}

/// Event to clear/reset the current state
class WorkPlanReset extends WorkPlanEvent {
  const WorkPlanReset();
}
