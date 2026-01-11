import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

/// Implementation of AuthRepository
/// Handles login, token storage, and auth state management
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, UserEntity>> loginUser({
    required String username,
    required String password,
  }) async {
    final result = await _remoteDataSource.login(
      username: username,
      password: password,
    );

    return result.fold(
      (failure) => Left(failure),
      (loginResult) async {
        // Store tokens and user data for session persistence
        await _localDataSource.saveAuthData(
          accessToken: loginResult.accessToken,
          refreshToken: loginResult.refreshToken ?? '',
          user: UserModel.fromEntity(loginResult.user),
        );
        return Right(loginResult.user.toEntity());
      },
    );
  }

  @override
  Future<bool> isAuthenticated() async {
    return _localDataSource.isAuthenticated();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final userModel = _localDataSource.getUser();
    return userModel?.toEntity();
  }

  @override
  Future<void> logout() async {
    await _localDataSource.clearAuthData();
  }

  @override
  Future<Either<Failure, UserEntity>> refreshToken() async {
    final refreshToken = _localDataSource.getRefreshToken();

    if (refreshToken == null) {
      return Left(AuthFailure('Tidak ada refresh token'));
    }

    final result = await _remoteDataSource.refreshToken(
      refreshToken: refreshToken,
    );

    return result.fold(
      (failure) => Left(failure),
      (accessToken) async {
        final user = _localDataSource.getUser();
        if (user == null) {
          return Left(AuthFailure('Data pengguna tidak ditemukan'));
        }

        // Update stored tokens
        await _localDataSource.saveAuthData(
          accessToken: accessToken,
          refreshToken: refreshToken,
          user: user,
        );

        return Right(user.toEntity());
      },
    );
  }
}
