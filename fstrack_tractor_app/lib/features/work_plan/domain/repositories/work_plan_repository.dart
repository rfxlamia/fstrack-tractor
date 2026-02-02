import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/operator_entity.dart';
import '../entities/work_plan_entity.dart';

/// Abstract repository interface for work plan operations
///
/// Follows the repository pattern with Either<Failure, Success> return type
/// for functional error handling.
abstract class WorkPlanRepository {
  /// Get all work plans
  Future<Either<Failure, List<WorkPlanEntity>>> getAll();

  /// Get a work plan by its ID
  Future<Either<Failure, WorkPlanEntity>> getById(String id);

  /// Create a new work plan
  Future<Either<Failure, WorkPlanEntity>> create(CreateWorkPlanParams params);

  /// Update an existing work plan
  Future<Either<Failure, WorkPlanEntity>> update(
    String id,
    UpdateWorkPlanParams params,
  );

  /// Get all available operators
  Future<Either<Failure, List<OperatorEntity>>> getOperators();
}

/// Parameters for creating a work plan
class CreateWorkPlanParams {
  final DateTime workDate;
  final String pattern;
  final String shift;
  final String locationId;
  final String unitId;
  final String? notes;

  const CreateWorkPlanParams({
    required this.workDate,
    required this.pattern,
    required this.shift,
    required this.locationId,
    required this.unitId,
    this.notes,
  });

  /// Validate parameters before sending to repository
  ///
  /// Throws ArgumentError if validation fails
  void validate() {
    if (pattern.trim().isEmpty) {
      throw ArgumentError('Pattern tidak boleh kosong');
    }
    if (shift.trim().isEmpty) {
      throw ArgumentError('Shift tidak boleh kosong');
    }
    if (locationId.trim().isEmpty) {
      throw ArgumentError('Location ID tidak boleh kosong');
    }
    if (unitId.trim().isEmpty) {
      throw ArgumentError('Unit ID tidak boleh kosong');
    }
    // Validate workDate is not too far in the past
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    if (workDate.isBefore(thirtyDaysAgo)) {
      throw ArgumentError('Tanggal kerja tidak boleh lebih dari 30 hari yang lalu');
    }
  }
}

/// Parameters for updating a work plan
class UpdateWorkPlanParams {
  final DateTime? workDate;
  final String? pattern;
  final String? shift;
  final String? locationId;
  final String? unitId;
  final int? operatorId;
  final String? status;
  final String? notes;

  const UpdateWorkPlanParams({
    this.workDate,
    this.pattern,
    this.shift,
    this.locationId,
    this.unitId,
    this.operatorId,
    this.status,
    this.notes,
  });
}
