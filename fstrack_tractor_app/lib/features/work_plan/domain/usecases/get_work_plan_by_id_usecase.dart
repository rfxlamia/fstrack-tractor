import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/work_plan_entity.dart';
import '../repositories/work_plan_repository.dart';

/// Use case for getting a single work plan by ID
///
/// Returns a work plan entity or a failure if not found.
@lazySingleton
class GetWorkPlanByIdUseCase {
  final WorkPlanRepository _repository;

  const GetWorkPlanByIdUseCase(this._repository);

  Future<Either<Failure, WorkPlanEntity>> call(String id) {
    return _repository.getById(id);
  }
}
