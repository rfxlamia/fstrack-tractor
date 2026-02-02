import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/work_plan_entity.dart';
import '../repositories/work_plan_repository.dart';

/// Use case for assigning an operator to a work plan
///
/// Only users with KASIE_FE role can assign operators.
/// The work plan must be in OPEN status to assign an operator.
@lazySingleton
class AssignOperatorUseCase {
  final WorkPlanRepository _repository;

  const AssignOperatorUseCase(this._repository);

  Future<Either<Failure, WorkPlanEntity>> call(AssignOperatorParams params) {
    return _repository.update(
      params.workPlanId,
      UpdateWorkPlanParams(
        operatorId: params.operatorId,
        status: 'CLOSED',
      ),
    );
  }
}

/// Parameters for assigning an operator
class AssignOperatorParams {
  final String workPlanId;
  final int operatorId;

  const AssignOperatorParams({
    required this.workPlanId,
    required this.operatorId,
  });
}
