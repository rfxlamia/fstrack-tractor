import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/repositories/work_plan_repository.dart';
import '../../domain/usecases/assign_operator_usecase.dart';
import '../../domain/usecases/create_work_plan_usecase.dart';
import '../../domain/usecases/get_operators_usecase.dart';
import '../../domain/usecases/get_work_plan_by_id_usecase.dart';
import '../../domain/usecases/get_work_plans_usecase.dart';
import 'work_plan_event.dart';
import 'work_plan_state.dart';

/// BLoC for work plan management
///
/// Handles all work plan operations including:
/// - Loading work plans
/// - Creating work plans
/// - Assigning operators
/// - Managing UI state
@injectable
class WorkPlanBloc extends Bloc<WorkPlanEvent, WorkPlanState> {
  final GetWorkPlansUseCase _getWorkPlansUseCase;
  final GetWorkPlanByIdUseCase _getWorkPlanByIdUseCase;
  final CreateWorkPlanUseCase _createWorkPlanUseCase;
  final AssignOperatorUseCase _assignOperatorUseCase;
  final GetOperatorsUseCase _getOperatorsUseCase;

  WorkPlanBloc(
    this._getWorkPlansUseCase,
    this._getWorkPlanByIdUseCase,
    this._createWorkPlanUseCase,
    this._assignOperatorUseCase,
    this._getOperatorsUseCase,
  ) : super(const WorkPlanInitial()) {
    on<LoadWorkPlansRequested>(_onLoadWorkPlansRequested);
    on<LoadWorkPlanByIdRequested>(_onLoadWorkPlanByIdRequested);
    on<CreateWorkPlanRequested>(_onCreateWorkPlanRequested);
    on<AssignOperatorRequested>(_onAssignOperatorRequested);
    on<LoadOperatorsRequested>(_onLoadOperatorsRequested);
    on<WorkPlanSelected>(_onWorkPlanSelected);
    on<OperatorSelected>(_onOperatorSelected);
    on<WorkPlanReset>(_onWorkPlanReset);
  }

  Future<void> _onLoadWorkPlansRequested(
    LoadWorkPlansRequested event,
    Emitter<WorkPlanState> emit,
  ) async {
    emit(const WorkPlanLoading());
    final result = await _getWorkPlansUseCase();
    result.fold(
      (failure) => emit(WorkPlanError(failure.message)),
      (workPlans) => emit(WorkPlansLoaded(workPlans: workPlans)),
    );
  }

  Future<void> _onLoadWorkPlanByIdRequested(
    LoadWorkPlanByIdRequested event,
    Emitter<WorkPlanState> emit,
  ) async {
    emit(const WorkPlanLoading());
    final result = await _getWorkPlanByIdUseCase(event.workPlanId);
    result.fold(
      (failure) => emit(WorkPlanError(failure.message)),
      (workPlan) => emit(WorkPlanLoaded(workPlan)),
    );
  }

  Future<void> _onCreateWorkPlanRequested(
    CreateWorkPlanRequested event,
    Emitter<WorkPlanState> emit,
  ) async {
    emit(const WorkPlanLoading());
    final result = await _createWorkPlanUseCase(
      CreateWorkPlanParams(
        workDate: event.workDate,
        pattern: event.pattern,
        shift: event.shift,
        locationId: event.locationId,
        unitId: event.unitId,
        notes: event.notes,
      ),
    );
    result.fold(
      (failure) => emit(WorkPlanError(failure.message)),
      (workPlan) => emit(WorkPlanCreated(workPlan)),
    );
  }

  Future<void> _onAssignOperatorRequested(
    AssignOperatorRequested event,
    Emitter<WorkPlanState> emit,
  ) async {
    emit(const WorkPlanLoading());
    final result = await _assignOperatorUseCase(
      AssignOperatorParams(
        workPlanId: event.workPlanId,
        operatorId: event.operatorId,
      ),
    );
    result.fold(
      (failure) => emit(WorkPlanError(failure.message)),
      (workPlan) => emit(OperatorAssigned(workPlan)),
    );
  }

  Future<void> _onLoadOperatorsRequested(
    LoadOperatorsRequested event,
    Emitter<WorkPlanState> emit,
  ) async {
    emit(const WorkPlanLoading());
    final result = await _getOperatorsUseCase();
    result.fold(
      (failure) => emit(WorkPlanError(failure.message)),
      (operators) => emit(OperatorsLoaded(operators: operators)),
    );
  }

  void _onWorkPlanSelected(
    WorkPlanSelected event,
    Emitter<WorkPlanState> emit,
  ) {
    if (state is WorkPlansLoaded) {
      final currentState = state as WorkPlansLoaded;
      emit(currentState.copyWith(selectedWorkPlan: event.workPlan));
    }
  }

  void _onOperatorSelected(
    OperatorSelected event,
    Emitter<WorkPlanState> emit,
  ) {
    if (state is OperatorsLoaded) {
      final currentState = state as OperatorsLoaded;
      emit(currentState.copyWith(selectedOperator: event.operator));
    }
  }

  void _onWorkPlanReset(
    WorkPlanReset event,
    Emitter<WorkPlanState> emit,
  ) {
    emit(const WorkPlanInitial());
  }
}
