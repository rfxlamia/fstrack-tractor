import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/error/failures.dart';
import 'package:fstrack_tractor/features/auth/domain/entities/user_entity.dart';
import 'package:fstrack_tractor/features/auth/domain/usecases/login_user_usecase.dart';
import 'package:fstrack_tractor/features/auth/domain/usecases/logout_user_usecase.dart';
import 'package:fstrack_tractor/features/auth/domain/usecases/validate_token_usecase.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_event.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/user_fixtures.dart';
import '../../../../mocks/mock_auth_repository.dart';

class MockLoginUserUseCase extends Mock implements LoginUserUseCase {}

class MockLogoutUserUseCase extends Mock implements LogoutUserUseCase {}

class MockValidateTokenUseCase extends Mock implements ValidateTokenUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUserUseCase mockLoginUserUseCase;
  late MockLogoutUserUseCase mockLogoutUserUseCase;
  late MockValidateTokenUseCase mockValidateTokenUseCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockLoginUserUseCase = MockLoginUserUseCase();
    mockLogoutUserUseCase = MockLogoutUserUseCase();
    mockValidateTokenUseCase = MockValidateTokenUseCase();
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(
      loginUserUseCase: mockLoginUserUseCase,
      logoutUserUseCase: mockLogoutUserUseCase,
      validateTokenUseCase: mockValidateTokenUseCase,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state should be AuthInitial', () {
      expect(authBloc.state, const AuthInitial());
    });

    group('LoginRequested', () {
      const testUsername = 'dev_kasie';
      const testPassword = 'DevPassword123';

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthSuccess] when login succeeds',
        build: () {
          when(() => mockLoginUserUseCase(
                rememberMe: any(named: 'rememberMe'),
                username: any(named: 'username'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => Right(UserFixtures.kasiePgUser()));
          return authBloc;
        },
        act: (bloc) => bloc.add(const LoginRequested(
          rememberMe: false,
          username: testUsername,
          password: testPassword,
        )),
        expect: () => [
          const AuthLoading(),
          isA<AuthSuccess>()
              .having((s) => s.user.fullName, 'fullName', 'Pak Suswanto'),
        ],
        verify: (_) {
          verify(() => mockLoginUserUseCase(
                rememberMe: any(named: 'rememberMe'),
                username: testUsername,
                password: testPassword,
              )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when login fails with wrong credentials',
        build: () {
          when(() => mockLoginUserUseCase(
                    rememberMe: any(named: 'rememberMe'),
                    username: any(named: 'username'),
                    password: any(named: 'password'),
                  ))
              .thenAnswer((_) async =>
                  Left(AuthFailure('Username atau password salah')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const LoginRequested(
          rememberMe: false,
          username: 'wrong',
          password: 'wrong',
        )),
        expect: () => [
          const AuthLoading(),
          isA<AuthError>().having(
              (e) => e.message, 'message', 'Username atau password salah'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when account is locked',
        build: () {
          when(() => mockLoginUserUseCase(
                    rememberMe: any(named: 'rememberMe'),
                    username: any(named: 'username'),
                    password: any(named: 'password'),
                  ))
              .thenAnswer((_) async =>
                  Left(AuthFailure('Akun terkunci selama 30 menit')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const LoginRequested(
          rememberMe: false,
          username: testUsername,
          password: 'wrong',
        )),
        expect: () => [
          const AuthLoading(),
          isA<AuthError>().having(
              (e) => e.message, 'message', 'Akun terkunci selama 30 menit'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when rate limited',
        build: () {
          when(() => mockLoginUserUseCase(
                    rememberMe: any(named: 'rememberMe'),
                    username: any(named: 'username'),
                    password: any(named: 'password'),
                  ))
              .thenAnswer((_) async => Left(
                  AuthFailure('Terlalu banyak percobaan. Tunggu 15 menit.')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const LoginRequested(
          rememberMe: false,
          username: testUsername,
          password: 'wrong',
        )),
        expect: () => [
          const AuthLoading(),
          isA<AuthError>().having((e) => e.message, 'message',
              'Terlalu banyak percobaan. Tunggu 15 menit.'),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when network error occurs',
        build: () {
          when(() => mockLoginUserUseCase(
                rememberMe: any(named: 'rememberMe'),
                username: any(named: 'username'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => Left(NetworkFailure()));
          return authBloc;
        },
        act: (bloc) => bloc.add(const LoginRequested(
          rememberMe: false,
          username: testUsername,
          password: testPassword,
        )),
        expect: () => [
          const AuthLoading(),
          isA<AuthError>().having(
              (e) => e.message, 'message', 'Tidak dapat terhubung ke server'),
        ],
      );
    });

    group('LogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when logout is requested',
        build: () {
          when(() => mockLogoutUserUseCase()).thenAnswer((_) async {});
          return authBloc;
        },
        act: (bloc) => bloc.add(const LogoutRequested()),
        expect: () => [const AuthUnauthenticated()],
        verify: (_) {
          verify(() => mockLogoutUserUseCase()).called(1);
        },
      );
    });

    group('CheckAuthStatus', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when no stored session',
        build: () {
          // Mock: token validation returns false (no valid token)
          when(() => mockValidateTokenUseCase()).thenAnswer((_) async => false);
          return authBloc;
        },
        act: (bloc) => bloc.add(const CheckAuthStatus()),
        expect: () => [const AuthUnauthenticated()],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthSuccess] when valid token exists',
        setUp: () {
          // Register fallback value for UserEntity
          registerFallbackValue(const UserEntity(
            id: '1',
            fullName: 'Test',
            estateId: '1',
            isFirstTime: false,
            role: UserRole.kasiePg,
          ));
        },
        build: () {
          // Mock: token validation returns true
          when(() => mockValidateTokenUseCase()).thenAnswer((_) async => true);

          // Use direct value return instead of async
          mockAuthRepository.mockUser = const UserEntity(
            id: '1',
            fullName: 'Test User',
            estateId: '1',
            isFirstTime: false,
            role: UserRole.kasiePg,
          );

          return authBloc;
        },
        act: (bloc) => bloc.add(const CheckAuthStatus()),
        expect: () => [
          const AuthSuccess(
            user: UserEntity(
              id: '1',
              fullName: 'Test User',
              estateId: '1',
              isFirstTime: false,
              role: UserRole.kasiePg,
            ),
          ),
        ],
      );
    });

    group('ClearError', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when clearing error state',
        build: () {
          when(() => mockLoginUserUseCase(
                    rememberMe: any(named: 'rememberMe'),
                    username: any(named: 'username'),
                    password: any(named: 'password'),
                  ))
              .thenAnswer((_) async =>
                  Left(AuthFailure('Username atau password salah')));
          return authBloc;
        },
        seed: () => const AuthError(message: 'Test error'),
        act: (bloc) => bloc.add(const ClearError()),
        expect: () => [const AuthUnauthenticated()],
      );
    });

    group('SessionExpiryChecked', () {
      blocTest<AuthBloc, AuthState>(
          'emits [AuthUnauthenticated] with sessionExpired reason when session expired and grace period passed',
          build: () {
            mockAuthRepository.mockTokenExpiry =
                DateTime.now().subtract(const Duration(hours: 25));

            when(() => mockLogoutUserUseCase()).thenAnswer((_) async {});
            return authBloc;
          },
          act: (bloc) => bloc.add(const SessionExpiryChecked()),
          expect: () => [
                const AuthUnauthenticated(reason: LogoutReason.sessionExpired),
              ],
          verify: (_) {
            verify(() => mockLogoutUserUseCase()).called(1);
          });

      blocTest<AuthBloc, AuthState>(
        'emits nothing when session is not expired',
        build: () {
          mockAuthRepository.mockTokenExpiry =
              DateTime.now().add(const Duration(hours: 1));
          return authBloc;
        },
        act: (bloc) => bloc.add(const SessionExpiryChecked()),
        expect: () => [],
      );
    });
  });
}
