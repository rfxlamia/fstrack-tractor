import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/work_plan_entity.dart';
import '../repositories/work_plan_repository.dart';

/// Use case for getting all work plans
///
/// Returns a list of work plans filtered by user's role and permissions.
@lazySingleton
class GetWorkPlansUseCase {
  final WorkPlanRepository _repository;

  const GetWorkPlansUseCase(this._repository);

  Future<Either<Failure, List<WorkPlanEntity>>> call() {
    return _repository.getAll();
  }
}
