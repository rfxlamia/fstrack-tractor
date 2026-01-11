import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/error/failures.dart';
import 'package:fstrack_tractor/features/auth/domain/usecases/login_user_usecase.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_event.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_state.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/user_fixtures.dart';

class MockLoginUserUseCase extends Mock implements LoginUserUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUserUseCase mockLoginUserUseCase;

  setUp(() {
    mockLoginUserUseCase = MockLoginUserUseCase();
    authBloc = AuthBloc(loginUserUseCase: mockLoginUserUseCase);
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
                username: any(named: 'username'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => Right(UserFixtures.kasieUser()));
          return authBloc;
        },
        act: (bloc) => bloc.add(const LoginRequested(
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
                username: testUsername,
                password: testPassword,
              )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [AuthLoading, AuthError] when login fails with wrong credentials',
        build: () {
          when(() => mockLoginUserUseCase(
                username: any(named: 'username'),
                password: any(named: 'password'),
              )).thenAnswer(
              (_) async => Left(AuthFailure('Username atau password salah')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const LoginRequested(
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
                username: any(named: 'username'),
                password: any(named: 'password'),
              )).thenAnswer(
              (_) async => Left(AuthFailure('Akun terkunci selama 30 menit')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const LoginRequested(
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
                username: any(named: 'username'),
                password: any(named: 'password'),
              )).thenAnswer((_) async =>
              Left(AuthFailure('Terlalu banyak percobaan. Tunggu 15 menit.')));
          return authBloc;
        },
        act: (bloc) => bloc.add(const LoginRequested(
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
                username: any(named: 'username'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => Left(NetworkFailure()));
          return authBloc;
        },
        act: (bloc) => bloc.add(const LoginRequested(
          username: testUsername,
          password: testPassword,
        )),
        expect: () => [
          const AuthLoading(),
          isA<AuthError>().having((e) => e.message, 'message',
              'Tidak dapat terhubung ke server'),
        ],
      );
    });

    group('LogoutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when logout is requested',
        build: () => authBloc,
        act: (bloc) => bloc.add(const LogoutRequested()),
        expect: () => [const AuthUnauthenticated()],
      );
    });

    group('CheckAuthStatus', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when no stored session',
        build: () => authBloc,
        act: (bloc) => bloc.add(const CheckAuthStatus()),
        expect: () => [const AuthUnauthenticated()],
      );
    });

    group('ClearError', () {
      blocTest<AuthBloc, AuthState>(
        'emits [AuthUnauthenticated] when clearing error state',
        build: () {
          when(() => mockLoginUserUseCase(
                username: any(named: 'username'),
                password: any(named: 'password'),
              )).thenAnswer(
              (_) async => Left(AuthFailure('Username atau password salah')));
          return authBloc;
        },
        seed: () => const AuthError(message: 'Test error'),
        act: (bloc) => bloc.add(const ClearError()),
        expect: () => [const AuthUnauthenticated()],
      );
    });
  });
}
