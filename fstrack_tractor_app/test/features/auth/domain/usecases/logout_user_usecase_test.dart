import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:fstrack_tractor/features/auth/domain/repositories/auth_repository.dart';
import 'package:fstrack_tractor/features/auth/domain/usecases/logout_user_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUserUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUserUseCase(mockRepository);
  });

  group('LogoutUserUseCase', () {
    test('should call repository.logout() successfully', () async {
      // Arrange
      when(() => mockRepository.logout()).thenAnswer((_) async {});

      // Act
      await useCase();

      // Assert
      verify(() => mockRepository.logout()).called(1);
    });

    test('should complete without error when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.logout()).thenAnswer((_) async {});

      // Act & Assert - should not throw
      await expectLater(useCase(), completes);
    });

    test('should propagate exception when repository throws', () async {
      // Arrange
      when(() => mockRepository.logout())
          .thenThrow(Exception('Storage error'));

      // Act & Assert
      await expectLater(
        useCase(),
        throwsA(isA<Exception>()),
      );
    });
  });
}
