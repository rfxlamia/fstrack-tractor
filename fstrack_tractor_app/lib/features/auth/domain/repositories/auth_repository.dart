import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// Repository interface for authentication operations
/// Follows Clean Architecture - domain layer defines interface,
/// data layer provides implementation
abstract class AuthRepository {
  /// Login with username and password
  /// Returns Either<Failure, UserEntity> for error handling
  Future<Either<Failure, UserEntity>> loginUser({
    required String username,
    required String password,
    required bool rememberMe,
  });

  /// Check if user is currently authenticated
  /// Returns true if valid token exists
  Future<bool> isAuthenticated();

  /// Get current user from local storage
  /// Returns null if not authenticated
  Future<UserEntity?> getCurrentUser();

  /// Logout and clear all auth data
  Future<void> logout();

  /// Refresh access token using refresh token
  /// Returns Either<Failure, UserEntity> with new tokens
  Future<Either<Failure, UserEntity>> refreshToken();

  /// Check if stored token is not expired (basic check)
  /// Note: For offline grace period logic, use ValidateTokenUseCase
  Future<bool> isTokenValid();

  /// Get token expiration DateTime
  /// Returns null if no token exists
  Future<DateTime?> getTokenExpiry();

  /// Check if session is expired
  Future<bool> isSessionExpired();

  /// Check if grace period has passed
  Future<bool> isGracePeriodPassed();
}
