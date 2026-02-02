import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/operator_entity.dart';
import '../repositories/work_plan_repository.dart';

/// Use case for getting all available operators
///
/// Used by KASIE_FE to select operators for assignment.
@lazySingleton
class GetOperatorsUseCase {
  final WorkPlanRepository _repository;

  const GetOperatorsUseCase(this._repository);

  Future<Either<Failure, List<OperatorEntity>>> call() {
    return _repository.getOperators();
  }
}
