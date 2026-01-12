import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/router/app_router.dart';
import 'package:fstrack_tractor/core/theme/app_theme.dart';
import 'package:fstrack_tractor/features/auth/domain/entities/user_entity.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_event.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_state.dart';
import 'package:fstrack_tractor/injection_container.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late StreamController<AuthState> streamController;

  setUpAll(() {
    registerFallbackValue(const LoginRequested(username: '', password: ''));
    // Allow reassignment for tests
    getIt.allowReassignment = true;
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    streamController = StreamController<AuthState>.broadcast();
    when(() => mockAuthBloc.stream).thenAnswer((_) => streamController.stream);

    // Register mock AuthBloc in GetIt so LoginPage can find it
    if (getIt.isRegistered<AuthBloc>()) {
      getIt.unregister<AuthBloc>();
    }
    getIt.registerSingleton<AuthBloc>(mockAuthBloc);
  });

  tearDown(() {
    streamController.close();
  });

  tearDownAll(() {
    if (getIt.isRegistered<AuthBloc>()) {
      getIt.unregister<AuthBloc>();
    }
    getIt.allowReassignment = false;
  });

  Widget createApp(AppRouter appRouter) {
    return BlocProvider<AuthBloc>.value(
      value: mockAuthBloc,
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: appRouter.router,
      ),
    );
  }

  group('AppRouter redirect widget tests - AC12', () {
    testWidgets('AC1: unauthenticated user sees login page', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
      final appRouter = AppRouter(authBloc: mockAuthBloc);

      await tester.pumpWidget(createApp(appRouter));
      await tester.pumpAndSettle();

      // Should show login page (LoginForm has "Masuk" header and button)
      expect(find.text('Masuk'), findsWidgets);
    });

    testWidgets('AC2: authenticated non-first-time user redirects to home',
        (tester) async {
      const user = UserEntity(
        id: '1',
        fullName: 'Test User',
        role: UserRole.operator,
        estateId: 'estate1',
        isFirstTime: false,
      );
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: user));
      final appRouter = AppRouter(authBloc: mockAuthBloc);

      await tester.pumpWidget(createApp(appRouter));
      await tester.pumpAndSettle();

      // Should redirect from login to home
      expect(find.text('FSTrack Tractor'), findsOneWidget);
      expect(find.text('Selamat datang, Test User!'), findsOneWidget);
    });

    testWidgets('AC6: authenticated first-time user redirects to onboarding',
        (tester) async {
      const user = UserEntity(
        id: '1',
        fullName: 'New User',
        role: UserRole.operator,
        estateId: 'estate1',
        isFirstTime: true,
      );
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: user));
      final appRouter = AppRouter(authBloc: mockAuthBloc);

      await tester.pumpWidget(createApp(appRouter));
      await tester.pumpAndSettle();

      // Should redirect from login to onboarding
      expect(find.text('Selamat Datang'), findsOneWidget);
      expect(find.text('Lanjutkan ke Home'), findsOneWidget);
    });

    testWidgets('AC6: first-time user can proceed from onboarding to home',
        (tester) async {
      const user = UserEntity(
        id: '1',
        fullName: 'New User',
        role: UserRole.operator,
        estateId: 'estate1',
        isFirstTime: true,
      );
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: user));
      final appRouter = AppRouter(authBloc: mockAuthBloc);

      await tester.pumpWidget(createApp(appRouter));
      await tester.pumpAndSettle();

      // Should be on onboarding
      expect(find.text('Selamat Datang'), findsOneWidget);

      // Tap continue button
      await tester.tap(find.text('Lanjutkan ke Home'));
      await tester.pumpAndSettle();

      // Should now be on home
      expect(find.text('FSTrack Tractor'), findsOneWidget);
      expect(find.text('Selamat datang, New User!'), findsOneWidget);
    });

    testWidgets('AC3: logout redirects to login', (tester) async {
      const user = UserEntity(
        id: '1',
        fullName: 'Test User',
        role: UserRole.operator,
        estateId: 'estate1',
        isFirstTime: false,
      );
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: user));
      final appRouter = AppRouter(authBloc: mockAuthBloc);

      await tester.pumpWidget(createApp(appRouter));
      await tester.pumpAndSettle();

      // Should be on home
      expect(find.text('FSTrack Tractor'), findsOneWidget);

      // Simulate logout by changing state and notifying router
      when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
      streamController.add(const AuthUnauthenticated());
      await tester.pumpAndSettle();

      // Should redirect to login
      expect(find.text('Masuk'), findsWidgets);
    });

    testWidgets('AC4: unauthenticated deep link to /home redirects to login',
        (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
      final appRouter = AppRouter(authBloc: mockAuthBloc);

      await tester.pumpWidget(createApp(appRouter));
      await tester.pumpAndSettle();

      // Try to navigate to home while unauthenticated
      appRouter.router.go('/home');
      await tester.pumpAndSettle();

      // Should be redirected to login
      expect(find.text('Masuk'), findsWidgets);
    });

    testWidgets(
        'AC4: unauthenticated deep link to /onboarding redirects to login',
        (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
      final appRouter = AppRouter(authBloc: mockAuthBloc);

      await tester.pumpWidget(createApp(appRouter));
      await tester.pumpAndSettle();

      // Try to navigate to onboarding while unauthenticated
      appRouter.router.go('/onboarding');
      await tester.pumpAndSettle();

      // Should be redirected to login
      expect(find.text('Masuk'), findsWidgets);
    });
  });
}
