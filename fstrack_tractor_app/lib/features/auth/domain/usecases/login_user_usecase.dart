import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Use case for logging in a user
/// Follows Clean Architecture - single responsibility, testable
@injectable
class LoginUserUseCase {
  final AuthRepository authRepository;

  const LoginUserUseCase({required this.authRepository});

  /// Execute login with username and password
  /// Returns Either<Failure, UserEntity>
  ///
  /// [username] - User's username
  /// [password] - User's password
  /// [rememberMe] - Whether to keep user logged in
  Future<Either<Failure, UserEntity>> call({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    // Validate inputs before making API call
    if (username.trim().isEmpty) {
      return Left(AuthFailure('Username tidak boleh kosong'));
    }

    if (password.isEmpty) {
      return Left(AuthFailure('Password tidak boleh kosong'));
    }

    return authRepository.loginUser(
      username: username.trim(),
      password: password,
      rememberMe: rememberMe,
    );
  }
}
