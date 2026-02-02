import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/work_plan_entity.dart';
import '../repositories/work_plan_repository.dart';

/// Use case for creating a new work plan
///
/// Only users with KASIE_PG role can create work plans.
@lazySingleton
class CreateWorkPlanUseCase {
  final WorkPlanRepository _repository;

  const CreateWorkPlanUseCase(this._repository);

  Future<Either<Failure, WorkPlanEntity>> call(CreateWorkPlanParams params) {
    // Validate at domain boundary
    try {
      params.validate();
    } on ArgumentError catch (e) {
      return Future.value(Left(ValidationFailure(e.message)));
    }
    return _repository.create(params);
  }
}
