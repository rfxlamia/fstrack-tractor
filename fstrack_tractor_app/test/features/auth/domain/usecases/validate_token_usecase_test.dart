import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/features/auth/domain/usecases/validate_token_usecase.dart';

import '../../../../mocks/mock_auth_repository.dart';
import '../../../../mocks/mock_connectivity_checker.dart';

void main() {
  group('ValidateTokenUseCase', () {
    late ValidateTokenUseCase usecase;
    late MockAuthRepository mockAuthRepository;
    late MockConnectivityChecker mockConnectivityChecker;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockConnectivityChecker = MockConnectivityChecker();
      usecase = ValidateTokenUseCase(
        mockAuthRepository,
        mockConnectivityChecker,
      );
    });

    tearDown(() {
      mockConnectivityChecker.dispose();
    });

    test('returns true when token is not expired', () async {
      // Arrange: Token expires in 10 days
      final expiresAt = DateTime.now().add(const Duration(days: 10));
      mockAuthRepository.mockTokenExpiry = expiresAt;

      // Act
      final result = await usecase();

      // Assert
      expect(result, true);
    });

    test('returns false when token expired and online', () async {
      // Arrange: Token expired 1 hour ago
      final expiresAt = DateTime.now().subtract(const Duration(hours: 1));
      mockAuthRepository.mockTokenExpiry = expiresAt;
      mockConnectivityChecker.setOnline(true); // Device is online

      // Act
      final result = await usecase();

      // Assert
      expect(result, false);
    });

    test('returns true when token expired < 24h and offline (grace period)',
        () async {
      // Arrange: Token expired 12 hours ago (within 24h grace period)
      final expiresAt = DateTime.now().subtract(const Duration(hours: 12));
      mockAuthRepository.mockTokenExpiry = expiresAt;
      mockConnectivityChecker.setOnline(false); // Device is offline

      // Act
      final result = await usecase();

      // Assert
      expect(result, true); // Grace period allows access
    });

    test('returns false when token expired > 24h and offline', () async {
      // Arrange: Token expired 48 hours ago (beyond grace period)
      final expiresAt = DateTime.now().subtract(const Duration(hours: 48));
      mockAuthRepository.mockTokenExpiry = expiresAt;
      mockConnectivityChecker.setOnline(false); // Device is offline

      // Act
      final result = await usecase();

      // Assert
      expect(result, false); // Beyond grace period
    });

    test('returns false when no token exists', () async {
      // Arrange: No token stored
      mockAuthRepository.mockTokenExpiry = null;

      // Act
      final result = await usecase();

      // Assert
      expect(result, false);
    });
  });
}
