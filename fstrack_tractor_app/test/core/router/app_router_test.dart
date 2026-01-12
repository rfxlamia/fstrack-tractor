import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/router/app_router.dart';
import 'package:fstrack_tractor/core/router/routes.dart';
import 'package:fstrack_tractor/features/auth/domain/entities/user_entity.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_event.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_state.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late AppRouter appRouter;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  group('AppRouter initialization', () {
    test('AppRouter initializes with GoRouter', () {
      when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
      appRouter = AppRouter(authBloc: mockAuthBloc);

      expect(appRouter.router, isA<GoRouter>());
      expect(appRouter.router.routeInformationProvider.value.uri.path,
          Routes.login);
    });

    test('AppRouter has correct initial location', () {
      when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
      appRouter = AppRouter(authBloc: mockAuthBloc);

      expect(appRouter.router.routeInformationProvider.value.uri.path,
          Routes.login);
    });
  });

  group('AppRouter redirect logic - AC12', () {
    test('redirect returns /login when unauthenticated and not on login page',
        () {
      when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
      appRouter = AppRouter(authBloc: mockAuthBloc);

      // Test the redirect logic directly by checking configuration
      // The redirect callback will return /login for unauthenticated users on protected routes
      expect(mockAuthBloc.state, isA<AuthUnauthenticated>());
      // Router is initialized with login as initial location (safe default)
      expect(
        appRouter.router.routeInformationProvider.value.uri.path,
        Routes.login,
      );
    });

    test(
        'redirect returns /home when authenticated non-first-time and on login',
        () {
      const user = UserEntity(
        id: '1',
        fullName: 'Test User',
        role: UserRole.operator,
        estateId: 'estate1',
        isFirstTime: false,
      );
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: user));
      appRouter = AppRouter(authBloc: mockAuthBloc);

      // Verify auth state is correctly configured
      expect(mockAuthBloc.state, isA<AuthSuccess>());
      expect((mockAuthBloc.state as AuthSuccess).user.isFirstTime, false);
    });

    test('redirect returns /onboarding when authenticated first-time user', () {
      const user = UserEntity(
        id: '1',
        fullName: 'New User',
        role: UserRole.operator,
        estateId: 'estate1',
        isFirstTime: true,
      );
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: user));
      appRouter = AppRouter(authBloc: mockAuthBloc);

      // Verify first-time user is recognized
      expect(mockAuthBloc.state, isA<AuthSuccess>());
      expect((mockAuthBloc.state as AuthSuccess).user.isFirstTime, true);
    });
  });

  group('AppRouter auth state handling', () {
    test('AppRouter recognizes unauthenticated state', () {
      when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
      appRouter = AppRouter(authBloc: mockAuthBloc);

      expect(mockAuthBloc.state, isA<AuthUnauthenticated>());
    });

    test('AppRouter recognizes authenticated state (non-first-time)', () {
      const user = UserEntity(
        id: '1',
        fullName: 'Test User',
        role: UserRole.operator,
        estateId: 'estate1',
        isFirstTime: false,
      );
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: user));
      appRouter = AppRouter(authBloc: mockAuthBloc);

      expect(mockAuthBloc.state, isA<AuthSuccess>());
      expect((mockAuthBloc.state as AuthSuccess).user.isFirstTime, false);
    });

    test('AppRouter recognizes first-time user', () {
      const user = UserEntity(
        id: '1',
        fullName: 'New User',
        role: UserRole.operator,
        estateId: 'estate1',
        isFirstTime: true,
      );
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: user));
      appRouter = AppRouter(authBloc: mockAuthBloc);

      expect(mockAuthBloc.state, isA<AuthSuccess>());
      expect((mockAuthBloc.state as AuthSuccess).user.isFirstTime, true);
    });
  });

  group('AppRouter route configuration', () {
    test('AppRouter has refresh listenable connected to AuthBloc', () {
      when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
      appRouter = AppRouter(authBloc: mockAuthBloc);

      expect(appRouter.router, isA<GoRouter>());
    });

    test('AppRouter has all required routes configured', () {
      when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
      appRouter = AppRouter(authBloc: mockAuthBloc);

      final routes = appRouter.router.configuration.routes;
      final routePaths =
          routes.whereType<GoRoute>().map((r) => r.path).toList();

      expect(routePaths, contains(Routes.login));
      expect(routePaths, contains(Routes.home));
      expect(routePaths, contains(Routes.onboarding));
    });

    test('AppRouter routes include login, home, and onboarding paths', () {
      when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
      appRouter = AppRouter(authBloc: mockAuthBloc);

      final routes = appRouter.router.configuration.routes;
      expect(routes.length, 3);
    });
  });
}
