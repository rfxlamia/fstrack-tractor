import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/api_client.dart';
import '../models/login_result.dart';
import '../models/user_model.dart';

/// Remote data source for authentication API calls
@lazySingleton
class AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSource({required ApiClient apiClient}) : _apiClient = apiClient;

  /// Login with username and password
  /// Returns LoginResult containing UserModel and tokens on success
  Future<Either<Failure, LoginResult>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return Right(LoginResult.fromJson(data));
      }

      // Handle error responses
      final errorData = response.data as Map<String, dynamic>?;
      final errorMessage = errorData?['message'] as String? ?? 'Login gagal';
      return Left(ServerFailure(errorMessage));
    } on DioException catch (e) {
      return Left(ErrorMapper.mapDioException(e));
    } on Exception catch (e) {
      return Left(ErrorMapper.mapException(e));
    }
  }

  /// Validate current token
  /// Returns UserModel if token is valid
  Future<Either<Failure, UserModel>> validateToken() async {
    try {
      final response = await _apiClient.dio.get(
        '/api/v1/auth/me',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return Right(UserModel.fromJson(data));
      }

      return Left(ServerFailure('Token tidak valid'));
    } on DioException catch (e) {
      return Left(ErrorMapper.mapDioException(e));
    } on Exception catch (e) {
      return Left(ErrorMapper.mapException(e));
    }
  }

  /// Refresh access token
  Future<Either<Failure, String>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '/api/v1/auth/refresh',
        data: {
          'refreshToken': refreshToken,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final accessToken = data['accessToken'] as String;
        return Right(accessToken);
      }

      return Left(ServerFailure('Gagal refresh token'));
    } on DioException catch (e) {
      return Left(ErrorMapper.mapDioException(e));
    } on Exception catch (e) {
      return Left(ErrorMapper.mapException(e));
    }
  }
}
