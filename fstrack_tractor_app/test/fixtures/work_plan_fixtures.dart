import 'package:fstrack_tractor/features/work_plan/domain/entities/work_plan_entity.dart';

/// Test fixtures for WorkPlan-related data
class WorkPlanFixtures {
  static WorkPlanEntity openWorkPlan() => WorkPlanEntity(
    id: 'wp-001',
    workDate: DateTime(2026, 2, 3),
    pattern: 'Rotasi',
    shift: 'Pagi',
    locationId: 'AFD01',
    unitId: 'TR01',
    status: 'OPEN',
    operatorId: null,
    notes: null,
    startTime: null,
    endTime: null,
    reportId: null,
    createdAt: DateTime(2026, 2, 1),
    updatedAt: DateTime(2026, 2, 1),
  );

  static WorkPlanEntity closedWorkPlan() => WorkPlanEntity(
    id: 'wp-002',
    workDate: DateTime(2026, 2, 4),
    pattern: 'Tetap',
    shift: 'Siang',
    locationId: 'AFD02',
    unitId: 'TR02',
    status: 'CLOSED',
    operatorId: 123,
    notes: null,
    startTime: null,
    endTime: null,
    reportId: null,
    createdAt: DateTime(2026, 2, 2),
    updatedAt: DateTime(2026, 2, 3),
  );

  static WorkPlanEntity cancelledWorkPlan() => WorkPlanEntity(
    id: 'wp-003',
    workDate: DateTime(2026, 2, 5),
    pattern: 'Rotasi',
    shift: 'Malam',
    locationId: 'AFD03',
    unitId: 'TR03',
    status: 'CANCEL',
    operatorId: null,
    notes: 'Dibatalkan karena cuaca buruk',
    startTime: null,
    endTime: null,
    reportId: null,
    createdAt: DateTime(2026, 2, 3),
    updatedAt: DateTime(2026, 2, 4),
  );

  static WorkPlanEntity longTextWorkPlan() => WorkPlanEntity(
    id: 'wp-004',
    workDate: DateTime(2026, 2, 6),
    pattern: 'Rotasi Panjang Sekali Nama Polanya',
    shift: 'Pagi-Siang-Malam Bergantian',
    locationId: 'AFD04-LOKASI-PANJANG',
    unitId: 'TR04-UNIT-PANJANG',
    status: 'OPEN',
    operatorId: null,
    notes: null,
    startTime: null,
    endTime: null,
    reportId: null,
    createdAt: DateTime(2026, 2, 4),
    updatedAt: DateTime(2026, 2, 4),
  );

  static List<WorkPlanEntity> workPlanList() => [
    openWorkPlan(),
    closedWorkPlan(),
    cancelledWorkPlan(),
  ];

  static List<WorkPlanEntity> emptyList() => [];
}

/// Extension for creating modified copies of WorkPlanEntity in tests
extension WorkPlanEntityTestExtension on WorkPlanEntity {
  WorkPlanEntity copyWith({
    String? id,
    DateTime? workDate,
    String? pattern,
    String? shift,
    String? locationId,
    String? unitId,
    int? operatorId,
    String? status,
    DateTime? startTime,
    DateTime? endTime,
    String? reportId,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkPlanEntity(
      id: id ?? this.id,
      workDate: workDate ?? this.workDate,
      pattern: pattern ?? this.pattern,
      shift: shift ?? this.shift,
      locationId: locationId ?? this.locationId,
      unitId: unitId ?? this.unitId,
      operatorId: operatorId ?? this.operatorId,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      reportId: reportId ?? this.reportId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
