import '../../domain/entities/work_plan_entity.dart';

/// Data model for work plan (schedule)
///
/// Handles JSON serialization/deserialization with camelCase field names
/// as used in the API, while the database uses snake_case.
///
/// ⚠️ IMPORTANT: This is a DATA layer model. Do NOT use directly in UI.
/// Always convert to WorkPlanEntity for presentation logic.
/// Use entity.statusDisplayText for UI display, NOT model fields.
class WorkPlanModel {
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

  const WorkPlanModel({
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

  /// Create from JSON (API response)
  factory WorkPlanModel.fromJson(Map<String, dynamic> json) {
    try {
      return WorkPlanModel(
        id: json['id'] as String,
        workDate: DateTime.parse(json['workDate'] as String),
        pattern: json['pattern'] as String,
        shift: json['shift'] as String,
        locationId: json['locationId'] as String,
        unitId: json['unitId'] as String,
        operatorId: json['operatorId'] as int?,
        status: json['status'] as String,
        startTime: json['startTime'] != null
            ? DateTime.parse(json['startTime'] as String)
            : null,
        endTime: json['endTime'] != null
            ? DateTime.parse(json['endTime'] as String)
            : null,
        reportId: json['reportId'] as String?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );
    } catch (e) {
      throw FormatException('Invalid work plan JSON format: $e');
    }
  }

  /// Convert to JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workDate': workDate.toIso8601String(),
      'pattern': pattern,
      'shift': shift,
      'locationId': locationId,
      'unitId': unitId,
      'operatorId': operatorId,
      'status': status,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'reportId': reportId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to domain entity
  WorkPlanEntity toEntity() {
    return WorkPlanEntity(
      id: id,
      workDate: workDate,
      pattern: pattern,
      shift: shift,
      locationId: locationId,
      unitId: unitId,
      operatorId: operatorId,
      status: status,
      startTime: startTime,
      endTime: endTime,
      reportId: reportId,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Create from domain entity
  factory WorkPlanModel.fromEntity(WorkPlanEntity entity) {
    return WorkPlanModel(
      id: entity.id,
      workDate: entity.workDate,
      pattern: entity.pattern,
      shift: entity.shift,
      locationId: entity.locationId,
      unitId: entity.unitId,
      operatorId: entity.operatorId,
      status: entity.status,
      startTime: entity.startTime,
      endTime: entity.endTime,
      reportId: entity.reportId,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Create a copy with modified fields
  ///
  /// ⚠️ LIMITATION: Cannot clear nullable fields (set to null).
  /// For example, cannot unassign operator using copyWith(operatorId: null).
  /// To clear nullable fields, create a new instance directly.
  WorkPlanModel copyWith({
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
    return WorkPlanModel(
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
