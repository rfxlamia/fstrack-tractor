import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/operator_model.dart';
import '../models/work_plan_model.dart';

/// Abstract interface for work plan remote data source
abstract class WorkPlanRemoteDataSource {
  /// Get all work plans
  Future<List<WorkPlanModel>> getAll();

  /// Get a work plan by ID
  Future<WorkPlanModel> getById(String id);

  /// Create a new work plan
  Future<WorkPlanModel> create(CreateWorkPlanRequest request);

  /// Update a work plan
  Future<WorkPlanModel> update(String id, UpdateWorkPlanRequest request);

  /// Get all operators
  Future<List<OperatorModel>> getOperators();
}

/// Implementation of work plan remote data source
@LazySingleton(as: WorkPlanRemoteDataSource)
class WorkPlanRemoteDataSourceImpl implements WorkPlanRemoteDataSource {
  final Dio _dio;

  WorkPlanRemoteDataSourceImpl(ApiClient apiClient) : _dio = apiClient.dio;

  @override
  Future<List<WorkPlanModel>> getAll() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/schedules');
    return (response.data ?? [])
        .map((json) => WorkPlanModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<WorkPlanModel> getById(String id) async {
    final response = await _dio.get<Map<String, dynamic>>('/api/v1/schedules/$id');
    if (response.data == null) {
      throw ServerException('Respons server kosong');
    }
    return WorkPlanModel.fromJson(response.data!);
  }

  @override
  Future<WorkPlanModel> create(CreateWorkPlanRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/schedules',
      data: request.toJson(),
    );
    if (response.data == null) {
      throw ServerException('Respons server kosong');
    }
    return WorkPlanModel.fromJson(response.data!);
  }

  @override
  Future<WorkPlanModel> update(String id, UpdateWorkPlanRequest request) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/api/v1/schedules/$id',
      data: request.toJson(),
    );
    if (response.data == null) {
      throw ServerException('Respons server kosong');
    }
    return WorkPlanModel.fromJson(response.data!);
  }

  @override
  Future<List<OperatorModel>> getOperators() async {
    final response = await _dio.get<List<dynamic>>('/api/v1/operators');
    return (response.data ?? [])
        .map((json) => OperatorModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

/// Request model for creating a work plan
class CreateWorkPlanRequest {
  final DateTime workDate;
  final String pattern;
  final String shift;
  final String locationId;
  final String unitId;
  final String? notes;

  const CreateWorkPlanRequest({
    required this.workDate,
    required this.pattern,
    required this.shift,
    required this.locationId,
    required this.unitId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'workDate': workDate.toIso8601String(),
      'pattern': pattern,
      'shift': shift,
      'locationId': locationId,
      'unitId': unitId,
      'notes': notes,
    };
  }
}

/// Request model for updating a work plan
class UpdateWorkPlanRequest {
  final DateTime? workDate;
  final String? pattern;
  final String? shift;
  final String? locationId;
  final String? unitId;
  final int? operatorId;
  final String? status;
  final String? notes;

  const UpdateWorkPlanRequest({
    this.workDate,
    this.pattern,
    this.shift,
    this.locationId,
    this.unitId,
    this.operatorId,
    this.status,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (workDate != null) data['workDate'] = workDate!.toIso8601String();
    if (pattern != null) data['pattern'] = pattern;
    if (shift != null) data['shift'] = shift;
    if (locationId != null) data['locationId'] = locationId;
    if (unitId != null) data['unitId'] = unitId;
    if (operatorId != null) data['operatorId'] = operatorId;
    if (status != null) data['status'] = status;
    if (notes != null) data['notes'] = notes;
    return data;
  }
}
