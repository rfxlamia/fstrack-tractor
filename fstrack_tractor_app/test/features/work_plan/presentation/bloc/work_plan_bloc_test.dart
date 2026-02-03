import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fstrack_tractor/core/error/failures.dart';
import 'package:fstrack_tractor/features/work_plan/domain/entities/operator_entity.dart';
import 'package:fstrack_tractor/features/work_plan/domain/entities/work_plan_entity.dart';
import 'package:fstrack_tractor/features/work_plan/domain/repositories/work_plan_repository.dart';
import 'package:fstrack_tractor/features/work_plan/domain/usecases/assign_operator_usecase.dart';
import 'package:fstrack_tractor/features/work_plan/domain/usecases/create_work_plan_usecase.dart';
import 'package:fstrack_tractor/features/work_plan/domain/usecases/get_operators_usecase.dart';
import 'package:fstrack_tractor/features/work_plan/domain/usecases/get_work_plan_by_id_usecase.dart';
import 'package:fstrack_tractor/features/work_plan/domain/usecases/get_work_plans_usecase.dart';
import 'package:fstrack_tractor/features/work_plan/presentation/bloc/work_plan_bloc.dart';
import 'package:fstrack_tractor/features/work_plan/presentation/bloc/work_plan_event.dart';
import 'package:fstrack_tractor/features/work_plan/presentation/bloc/work_plan_state.dart';

class MockGetWorkPlansUseCase extends Mock implements GetWorkPlansUseCase {}

class MockGetWorkPlanByIdUseCase extends Mock implements GetWorkPlanByIdUseCase {}

class MockCreateWorkPlanUseCase extends Mock implements CreateWorkPlanUseCase {}

class MockAssignOperatorUseCase extends Mock implements AssignOperatorUseCase {}

class MockGetOperatorsUseCase extends Mock implements GetOperatorsUseCase {}

class FakeCreateWorkPlanParams extends Fake implements CreateWorkPlanParams {}

class FakeAssignOperatorParams extends Fake implements AssignOperatorParams {}

void main() {
  late WorkPlanBloc bloc;
  late MockGetWorkPlansUseCase mockGetWorkPlansUseCase;
  late MockGetWorkPlanByIdUseCase mockGetWorkPlanByIdUseCase;
  late MockCreateWorkPlanUseCase mockCreateWorkPlanUseCase;
  late MockAssignOperatorUseCase mockAssignOperatorUseCase;
  late MockGetOperatorsUseCase mockGetOperatorsUseCase;

  setUpAll(() {
    registerFallbackValue(FakeCreateWorkPlanParams());
    registerFallbackValue(FakeAssignOperatorParams());
  });

  setUp(() {
    mockGetWorkPlansUseCase = MockGetWorkPlansUseCase();
    mockGetWorkPlanByIdUseCase = MockGetWorkPlanByIdUseCase();
    mockCreateWorkPlanUseCase = MockCreateWorkPlanUseCase();
    mockAssignOperatorUseCase = MockAssignOperatorUseCase();
    mockGetOperatorsUseCase = MockGetOperatorsUseCase();

    bloc = WorkPlanBloc(
      mockGetWorkPlansUseCase,
      mockGetWorkPlanByIdUseCase,
      mockCreateWorkPlanUseCase,
      mockAssignOperatorUseCase,
      mockGetOperatorsUseCase,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('LoadWorkPlansRequested', () {
    final testWorkPlans = [
      WorkPlanEntity(
        id: '1',
        workDate: DateTime(2026, 2, 3),
        pattern: 'Rotasi',
        shift: 'Pagi',
        locationId: 'AFD01',
        unitId: 'TR01',
        status: 'OPEN',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    blocTest<WorkPlanBloc, WorkPlanState>(
      'emits [Loading, WorkPlansLoaded] when successful',
      build: () {
        when(() => mockGetWorkPlansUseCase())
            .thenAnswer((_) async => Right(testWorkPlans));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadWorkPlansRequested()),
      expect: () => [
        const WorkPlanLoading(),
        WorkPlansLoaded(workPlans: testWorkPlans),
      ],
    );

    blocTest<WorkPlanBloc, WorkPlanState>(
      'emits [Loading, Error] when fails',
      build: () {
        when(() => mockGetWorkPlansUseCase())
            .thenAnswer((_) async => Left(ServerFailure('Gagal memuat data')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadWorkPlansRequested()),
      expect: () => [
        const WorkPlanLoading(),
        const WorkPlanError('Gagal memuat data'),
      ],
    );
  });

  group('CreateWorkPlanRequested', () {
    final testWorkPlan = WorkPlanEntity(
      id: '1',
      workDate: DateTime(2026, 2, 3),
      pattern: 'Rotasi',
      shift: 'Pagi',
      locationId: 'AFD01',
      unitId: 'TR01',
      status: 'OPEN',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final testWorkPlans = [testWorkPlan];

    blocTest<WorkPlanBloc, WorkPlanState>(
      'emits [Loading, Created, Loading, WorkPlansLoaded] on success with auto-refresh',
      build: () {
        when(() => mockCreateWorkPlanUseCase(any()))
            .thenAnswer((_) async => Right(testWorkPlan));
        when(() => mockGetWorkPlansUseCase())
            .thenAnswer((_) async => Right(testWorkPlans));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateWorkPlanRequested(
        workDate: DateTime(2026, 2, 3),
        pattern: 'Rotasi',
        shift: 'Pagi',
        locationId: 'AFD01',
        unitId: 'TR01',
      )),
      expect: () => [
        const WorkPlanLoading(),
        WorkPlanCreated(testWorkPlan),
        const WorkPlanLoading(),
        WorkPlansLoaded(workPlans: testWorkPlans),
      ],
    );

    blocTest<WorkPlanBloc, WorkPlanState>(
      'emits [Loading, Error] on failure',
      build: () {
        when(() => mockCreateWorkPlanUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure('Gagal membuat rencana kerja')));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateWorkPlanRequested(
        workDate: DateTime(2026, 2, 3),
        pattern: 'Rotasi',
        shift: 'Pagi',
        locationId: 'AFD01',
        unitId: 'TR01',
      )),
      expect: () => [
        const WorkPlanLoading(),
        const WorkPlanError('Gagal membuat rencana kerja'),
      ],
    );

    blocTest<WorkPlanBloc, WorkPlanState>(
      'emits [Loading, Error] on validation failure',
      build: () {
        when(() => mockCreateWorkPlanUseCase(any()))
            .thenAnswer((_) async => Left(ValidationFailure('Semua field wajib diisi')));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateWorkPlanRequested(
        workDate: DateTime(2026, 2, 3),
        pattern: 'Rotasi',
        shift: 'Pagi',
        locationId: 'AFD01',
        unitId: 'TR01',
      )),
      expect: () => [
        const WorkPlanLoading(),
        const WorkPlanError('Semua field wajib diisi'),
      ],
    );
  });

  group('LoadWorkPlanByIdRequested', () {
    final testWorkPlan = WorkPlanEntity(
      id: '1',
      workDate: DateTime(2026, 2, 3),
      pattern: 'Rotasi',
      shift: 'Pagi',
      locationId: 'AFD01',
      unitId: 'TR01',
      status: 'OPEN',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    blocTest<WorkPlanBloc, WorkPlanState>(
      'emits [Loading, WorkPlanLoaded] when successful',
      build: () {
        when(() => mockGetWorkPlanByIdUseCase('1'))
            .thenAnswer((_) async => Right(testWorkPlan));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadWorkPlanByIdRequested('1')),
      expect: () => [
        const WorkPlanLoading(),
        WorkPlanLoaded(testWorkPlan),
      ],
    );

    blocTest<WorkPlanBloc, WorkPlanState>(
      'emits [Loading, Error] when not found',
      build: () {
        when(() => mockGetWorkPlanByIdUseCase('999'))
            .thenAnswer((_) async => Left(ServerFailure('Data tidak ditemukan')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadWorkPlanByIdRequested('999')),
      expect: () => [
        const WorkPlanLoading(),
        const WorkPlanError('Data tidak ditemukan'),
      ],
    );
  });

  group('AssignOperatorRequested', () {
    final testWorkPlan = WorkPlanEntity(
      id: '1',
      workDate: DateTime(2026, 2, 3),
      pattern: 'Rotasi',
      shift: 'Pagi',
      locationId: 'AFD01',
      unitId: 'TR01',
      operatorId: 123,
      status: 'CLOSED',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    blocTest<WorkPlanBloc, WorkPlanState>(
      'emits [Loading, OperatorAssigned] when successful',
      build: () {
        when(() => mockAssignOperatorUseCase(any()))
            .thenAnswer((_) async => Right(testWorkPlan));
        return bloc;
      },
      act: (bloc) => bloc.add(const AssignOperatorRequested(
        workPlanId: '1',
        operatorId: 123,
      )),
      expect: () => [
        const WorkPlanLoading(),
        OperatorAssigned(testWorkPlan),
      ],
    );

    blocTest<WorkPlanBloc, WorkPlanState>(
      'emits [Loading, Error] when fails',
      build: () {
        when(() => mockAssignOperatorUseCase(any()))
            .thenAnswer((_) async => Left(ServerFailure('Gagal menugaskan operator')));
        return bloc;
      },
      act: (bloc) => bloc.add(const AssignOperatorRequested(
        workPlanId: '1',
        operatorId: 123,
      )),
      expect: () => [
        const WorkPlanLoading(),
        const WorkPlanError('Gagal menugaskan operator'),
      ],
    );
  });

  group('LoadOperatorsRequested', () {
    final testOperators = [
      const OperatorEntity(id: 1, name: 'John Doe', isActive: true),
      const OperatorEntity(id: 2, name: 'Jane Smith', isActive: true),
    ];

    blocTest<WorkPlanBloc, WorkPlanState>(
      'emits [Loading, OperatorsLoaded] when successful',
      build: () {
        when(() => mockGetOperatorsUseCase())
            .thenAnswer((_) async => Right(testOperators));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadOperatorsRequested()),
      expect: () => [
        const WorkPlanLoading(),
        OperatorsLoaded(operators: testOperators),
      ],
    );

    blocTest<WorkPlanBloc, WorkPlanState>(
      'emits [Loading, Error] when fails',
      build: () {
        when(() => mockGetOperatorsUseCase())
            .thenAnswer((_) async => Left(ServerFailure('Gagal memuat operator')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadOperatorsRequested()),
      expect: () => [
        const WorkPlanLoading(),
        const WorkPlanError('Gagal memuat operator'),
      ],
    );
  });

  group('WorkPlanSelected', () {
    final testWorkPlan = WorkPlanEntity(
      id: '1',
      workDate: DateTime(2026, 2, 3),
      pattern: 'Rotasi',
      shift: 'Pagi',
      locationId: 'AFD01',
      unitId: 'TR01',
      status: 'OPEN',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final testWorkPlans = [testWorkPlan];

    blocTest<WorkPlanBloc, WorkPlanState>(
      'updates selectedWorkPlan in WorkPlansLoaded state',
      build: () => bloc,
      seed: () => WorkPlansLoaded(workPlans: testWorkPlans),
      act: (bloc) => bloc.add(WorkPlanSelected(testWorkPlan)),
      expect: () => [
        WorkPlansLoaded(workPlans: testWorkPlans, selectedWorkPlan: testWorkPlan),
      ],
    );

    blocTest<WorkPlanBloc, WorkPlanState>(
      'does not emit when not in WorkPlansLoaded state',
      build: () => bloc,
      seed: () => const WorkPlanInitial(),
      act: (bloc) => bloc.add(WorkPlanSelected(testWorkPlan)),
      expect: () => [],
    );
  });

  group('OperatorSelected', () {
    const testOperator = OperatorEntity(id: 1, name: 'John Doe', isActive: true);
    final testOperators = [testOperator];

    blocTest<WorkPlanBloc, WorkPlanState>(
      'updates selectedOperator in OperatorsLoaded state',
      build: () => bloc,
      seed: () => OperatorsLoaded(operators: testOperators),
      act: (bloc) => bloc.add(const OperatorSelected(testOperator)),
      expect: () => [
        OperatorsLoaded(operators: testOperators, selectedOperator: testOperator),
      ],
    );

    blocTest<WorkPlanBloc, WorkPlanState>(
      'does not emit when not in OperatorsLoaded state',
      build: () => bloc,
      seed: () => const WorkPlanInitial(),
      act: (bloc) => bloc.add(const OperatorSelected(null)),
      expect: () => [],
    );
  });

  group('WorkPlanReset', () {
    blocTest<WorkPlanBloc, WorkPlanState>(
      'emits WorkPlanInitial',
      build: () => bloc,
      seed: () => const WorkPlanLoading(),
      act: (bloc) => bloc.add(const WorkPlanReset()),
      expect: () => [
        const WorkPlanInitial(),
      ],
    );
  });
}
