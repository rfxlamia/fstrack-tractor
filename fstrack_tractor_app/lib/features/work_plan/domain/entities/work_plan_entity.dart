import 'package:equatable/equatable.dart';

/// Entity representing a work plan (schedule) in the domain layer
///
/// Maps to the production database schema:
/// - schedules.id: UUID (String)
/// - schedules.operator_id: INTEGER nullable
/// - schedules.location_id: VARCHAR(32)
/// - schedules.unit_id: VARCHAR(16)
/// - schedules.status: ENUM ('OPEN', 'CLOSED', 'CANCEL')
class WorkPlanEntity extends Equatable {
  final String id;
  final DateTime workDate;
  final String pattern;
  final String shift;
  final String locationId;
  final String unitId;
  final int? operatorId;
  final String status;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? reportId;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkPlanEntity({
    required this.id,
    required this.workDate,
    required this.pattern,
    required this.shift,
    required this.locationId,
    required this.unitId,
    this.operatorId,
    required this.status,
    this.startTime,
    this.endTime,
    this.reportId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if this work plan is in OPEN status
  bool get isOpen => status == 'OPEN';

  /// Check if this work plan is in CLOSED status (assigned to operator)
  bool get isClosed => status == 'CLOSED';

  /// Check if this work plan is in CANCEL status
  bool get isCancelled => status == 'CANCEL';

  /// Check if an operator has been assigned
  bool get hasOperator => operatorId != null;

  /// Get display status text in Bahasa Indonesia
  String get statusDisplayText {
    return switch (status) {
      'OPEN' => 'Terbuka',
      'CLOSED' => 'Ditugaskan',
      'CANCEL' => 'Dibatalkan',
      _ => status,
    };
  }

  @override
  List<Object?> get props => [
        id,
        workDate,
        pattern,
        shift,
        locationId,
        unitId,
        operatorId,
        status,
        startTime,
        endTime,
        reportId,
        notes,
        createdAt,
        updatedAt,
      ];
}
