import 'package:injectable/injectable.dart';

import '../models/work_plan_model.dart';

/// Abstract interface for work plan local data source
///
/// Used for caching work plans locally.
abstract class WorkPlanLocalDataSource {
  /// Cache work plans locally
  Future<void> cacheWorkPlans(List<WorkPlanModel> workPlans);

  /// Get cached work plans
  Future<List<WorkPlanModel>> getCachedWorkPlans();

  /// Cache a single work plan
  Future<void> cacheWorkPlan(WorkPlanModel workPlan);

  /// Get a cached work plan by ID
  Future<WorkPlanModel?> getCachedWorkPlan(String id);

  /// Clear all cached work plans
  Future<void> clearCache();
}

/// Implementation of work plan local data source
///
/// Currently a stub implementation - can be enhanced with Hive or SQLite
/// for offline support in future iterations.
@LazySingleton(as: WorkPlanLocalDataSource)
class WorkPlanLocalDataSourceImpl implements WorkPlanLocalDataSource {
  // TODO: Implement with Hive or SQLite for offline support
  // For now, this is a stub that doesn't actually cache anything

  @override
  Future<void> cacheWorkPlans(List<WorkPlanModel> workPlans) async {
    // Stub implementation
  }

  @override
  Future<List<WorkPlanModel>> getCachedWorkPlans() async {
    // Stub implementation - returns empty list
    return [];
  }

  @override
  Future<void> cacheWorkPlan(WorkPlanModel workPlan) async {
    // Stub implementation
  }

  @override
  Future<WorkPlanModel?> getCachedWorkPlan(String id) async {
    // Stub implementation - returns null
    return null;
  }

  @override
  Future<void> clearCache() async {
    // Stub implementation
  }
}
