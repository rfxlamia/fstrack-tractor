import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/error/failures.dart';
import 'package:fstrack_tractor/features/auth/domain/repositories/auth_repository.dart';
import 'package:fstrack_tractor/features/auth/domain/usecases/login_user_usecase.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/user_fixtures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUserUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginUserUseCase(authRepository: mockAuthRepository);
  });

  group('LoginUserUseCase', () {
    const testUsername = 'dev_kasie';
    const testPassword = 'DevPassword123';

    test('should return UserEntity when login succeeds', () async {
      // Arrange
      when(() => mockAuthRepository.loginUser(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right(UserFixtures.kasieUser()));

      // Act
      final result = await useCase(
        username: testUsername,
        password: testPassword,
      );

      // Assert
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right, got Left with $failure'),
        (user) {
          expect(user.fullName, 'Pak Suswanto');
          expect(user.role.name, 'kasie');
        },
      );
      verify(() => mockAuthRepository.loginUser(
            username: testUsername,
            password: testPassword,
          )).called(1);
    });

    test('should return AuthFailure when username is empty', () async {
      // Act
      final result = await useCase(
        username: '',
        password: testPassword,
      );

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, 'Username tidak boleh kosong');
        },
        (user) => fail('Expected Left, got Right with $user'),
      );
      verifyNever(() => mockAuthRepository.loginUser(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ));
    });

    test('should return AuthFailure when username is only whitespace', () async {
      // Act
      final result = await useCase(
        username: '   ',
        password: testPassword,
      );

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, 'Username tidak boleh kosong');
        },
        (user) => fail('Expected Left, got Right with $user'),
      );
    });

    test('should return AuthFailure when password is empty', () async {
      // Act
      final result = await useCase(
        username: testUsername,
        password: '',
      );

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, 'Password tidak boleh kosong');
        },
        (user) => fail('Expected Left, got Right with $user'),
      );
      verifyNever(() => mockAuthRepository.loginUser(
            username: any(named: 'username'),
            password: any(named: 'password'),
          ));
    });

    test('should trim username before calling repository', () async {
      // Arrange
      when(() => mockAuthRepository.loginUser(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Right(UserFixtures.kasieUser()));

      // Act
      await useCase(
        username: '  $testUsername  ',
        password: testPassword,
      );

      // Assert
      verify(() => mockAuthRepository.loginUser(
            username: testUsername,
            password: testPassword,
          )).called(1);
    });

    test('should return failure when repository returns failure', () async {
      // Arrange
      when(() => mockAuthRepository.loginUser(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer(
          (_) async => Left(AuthFailure('Username atau password salah')));

      // Act
      final result = await useCase(
        username: testUsername,
        password: 'wrongpassword',
      );

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) {
          expect(failure.message, 'Username atau password salah');
        },
        (user) => fail('Expected Left, got Right'),
      );
    });

    test('should return NetworkFailure when network error occurs', () async {
      // Arrange
      when(() => mockAuthRepository.loginUser(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => Left(NetworkFailure()));

      // Act
      final result = await useCase(
        username: testUsername,
        password: testPassword,
      );

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(failure.message, 'Tidak dapat terhubung ke server');
        },
        (user) => fail('Expected Left, got Right'),
      );
    });
  });
}
