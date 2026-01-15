import 'package:dartz/dartz.dart';
import 'package:fstrack_tractor/core/error/failures.dart';
import 'package:fstrack_tractor/features/auth/domain/entities/user_entity.dart';
import 'package:fstrack_tractor/features/auth/domain/repositories/auth_repository.dart';

/// Mock implementation of AuthRepository for testing
class MockAuthRepository implements AuthRepository {
  DateTime? mockTokenExpiry;
  UserEntity? mockUser;
  bool mockIsAuthenticated = false;
  Either<Failure, UserEntity>? mockLoginResult;

  @override
  Future<Either<Failure, UserEntity>> loginUser({
    required String username,
    required String password,
    required bool rememberMe,
  }) async {
    return mockLoginResult ??
        Right(mockUser ??
            const UserEntity(
              id: '1',
              fullName: 'Test User',
              estateId: '1',
              isFirstTime: false,
              role: UserRole.kasie,
            ));
  }

  @override
  Future<bool> isAuthenticated() async {
    return mockIsAuthenticated;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    return mockUser;
  }

  @override
  Future<void> logout() async {
    mockUser = null;
    mockIsAuthenticated = false;
    mockTokenExpiry = null;
  }

  @override
  Future<Either<Failure, UserEntity>> refreshToken() async {
    return mockLoginResult ?? Right(mockUser!);
  }

  @override
  Future<bool> isTokenValid() async {
    // Simple expiry check - matches simplified AuthRepositoryImpl
    // Grace period logic is in ValidateTokenUseCase, not here
    if (mockTokenExpiry == null) return false;
    return mockTokenExpiry!.isAfter(DateTime.now());
  }

  @override
  Future<DateTime?> getTokenExpiry() async {
    return mockTokenExpiry;
  }

  @override
  Future<bool> isSessionExpired() async {
    if (mockTokenExpiry == null) return true;
    return DateTime.now().isAfter(mockTokenExpiry!);
  }

  @override
  Future<bool> isGracePeriodPassed() async {
    if (mockTokenExpiry == null) return true;
    return DateTime.now()
        .isAfter(mockTokenExpiry!.add(const Duration(hours: 24)));
  }
}
