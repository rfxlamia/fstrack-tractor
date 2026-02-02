import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/operator_entity.dart';
import '../../domain/entities/work_plan_entity.dart';
import '../../domain/repositories/work_plan_repository.dart';
import '../datasources/work_plan_local_datasource.dart';
import '../datasources/work_plan_remote_datasource.dart';

/// Implementation of work plan repository
///
/// Follows the repository pattern with remote-first strategy.
/// Falls back to local cache when offline (future enhancement).
@LazySingleton(as: WorkPlanRepository)
class WorkPlanRepositoryImpl implements WorkPlanRepository {
  final WorkPlanRemoteDataSource _remoteDataSource;
  final WorkPlanLocalDataSource _localDataSource;

  WorkPlanRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  @override
  Future<Either<Failure, List<WorkPlanEntity>>> getAll() async {
    try {
      final models = await _remoteDataSource.getAll();
      final entities = models.map((m) => m.toEntity()).toList();
      // Cache for offline support
      await _localDataSource.cacheWorkPlans(models);
      return Right(entities);
    } on ServerException catch (e) {
      // Try to return cached data on server error
      try {
        final cached = await _localDataSource.getCachedWorkPlans();
        if (cached.isNotEmpty) {
          // ignore: avoid_print
          print('⚠️ WorkPlan: Using cached data due to server error: ${e.message}');
          return Right(cached.map((m) => m.toEntity()).toList());
        }
      } catch (cacheError) {
        // ignore: avoid_print
        print('❌ WorkPlan: Cache error while falling back: $cacheError');
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal memuat rencana kerja'));
    }
  }

  @override
  Future<Either<Failure, WorkPlanEntity>> getById(String id) async {
    try {
      final model = await _remoteDataSource.getById(id);
      final entity = model.toEntity();
      await _localDataSource.cacheWorkPlan(model);
      return Right(entity);
    } on ServerException catch (e) {
      // Try cache
      try {
        final cached = await _localDataSource.getCachedWorkPlan(id);
        if (cached != null) {
          // ignore: avoid_print
          print('⚠️ WorkPlan: Using cached data due to server error: ${e.message}');
          return Right(cached.toEntity());
        }
      } catch (cacheError) {
        // ignore: avoid_print
        print('❌ WorkPlan: Cache error while falling back: $cacheError');
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal memuat detail rencana kerja'));
    }
  }

  @override
  Future<Either<Failure, WorkPlanEntity>> create(
    CreateWorkPlanParams params,
  ) async {
    try {
      final request = CreateWorkPlanRequest(
        workDate: params.workDate,
        pattern: params.pattern,
        shift: params.shift,
        locationId: params.locationId,
        unitId: params.unitId,
        notes: params.notes,
      );
      final model = await _remoteDataSource.create(request);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal membuat rencana kerja'));
    }
  }

  @override
  Future<Either<Failure, WorkPlanEntity>> update(
    String id,
    UpdateWorkPlanParams params,
  ) async {
    try {
      final request = UpdateWorkPlanRequest(
        workDate: params.workDate,
        pattern: params.pattern,
        shift: params.shift,
        locationId: params.locationId,
        unitId: params.unitId,
        operatorId: params.operatorId,
        status: params.status,
        notes: params.notes,
      );
      final model = await _remoteDataSource.update(id, request);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal memperbarui rencana kerja'));
    }
  }

  @override
  Future<Either<Failure, List<OperatorEntity>>> getOperators() async {
    try {
      final models = await _remoteDataSource.getOperators();
      final entities = models.map((m) => m.toEntity()).toList();
      return Right(entities);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Gagal memuat daftar operator'));
    }
  }
}
