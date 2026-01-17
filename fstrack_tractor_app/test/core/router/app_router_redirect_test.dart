import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/router/app_router.dart';
import 'package:fstrack_tractor/core/theme/app_theme.dart';
import 'package:fstrack_tractor/features/auth/domain/entities/user_entity.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_state.dart';
import 'package:fstrack_tractor/features/home/presentation/widgets/greeting_header.dart';
import 'package:mocktail/mocktail.dart';
import '../../helpers/home_page_test_helper.dart';

void main() {
  final helper = HomePageTestHelper(registerAuthBlocInGetIt: true);

  setUpAll(() => helper.setUpAll());

  setUp(() => helper.setUp());
  tearDown(() => helper.tearDown());
  tearDownAll(() => helper.tearDownAll());

  Widget createApp(AppRouter appRouter) {
    return BlocProvider<AuthBloc>.value(
      value: helper.mockAuthBloc,
      child: MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: appRouter.router,
      ),
    );
  }

  group('AppRouter redirect widget tests - AC12', () {
    testWidgets('AC1: unauthenticated user sees login page', (tester) async {
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthUnauthenticated());
      final appRouter = AppRouter(authBloc: helper.mockAuthBloc);

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
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: user));
      final appRouter = AppRouter(authBloc: helper.mockAuthBloc);

      await tester.pumpWidget(createApp(appRouter));
      // Use pump() instead of pumpAndSettle() due to Timer in WeatherWidget
      await tester.pump();
      await tester.pump(weatherWidgetInitDelay);

      // Should redirect from login to home
      expect(find.text('FSTrack Tractor'), findsOneWidget);
      // Check for GreetingHeader widget (time-based greeting)
      expect(find.byType(GreetingHeader), findsOneWidget);
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
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: user));
      final appRouter = AppRouter(authBloc: helper.mockAuthBloc);

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
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: user));
      final appRouter = AppRouter(authBloc: helper.mockAuthBloc);

      await tester.pumpWidget(createApp(appRouter));
      await tester.pumpAndSettle();

      // Should be on onboarding
      expect(find.text('Selamat Datang'), findsOneWidget);

      // Tap continue button
      await tester.tap(find.text('Lanjutkan ke Home'));
      // Use pump() instead of pumpAndSettle() due to Timer in WeatherWidget
      await tester.pump();
      await tester.pump(weatherWidgetInitDelay);

      // Should now be on home
      expect(find.text('FSTrack Tractor'), findsOneWidget);
      // Check for GreetingHeader widget (time-based greeting)
      expect(find.byType(GreetingHeader), findsOneWidget);
    });

    testWidgets('AC3: logout redirects to login', (tester) async {
      const user = UserEntity(
        id: '1',
        fullName: 'Test User',
        role: UserRole.operator,
        estateId: 'estate1',
        isFirstTime: false,
      );
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: user));
      final appRouter = AppRouter(authBloc: helper.mockAuthBloc);

      await tester.pumpWidget(createApp(appRouter));
      // Use pump() instead of pumpAndSettle() due to Timer in WeatherWidget
      await tester.pump();
      await tester.pump(weatherWidgetInitDelay);

      // Should be on home
      expect(find.text('FSTrack Tractor'), findsOneWidget);

      // Simulate logout by changing state and notifying router
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthUnauthenticated());
      helper.authStreamController.add(const AuthUnauthenticated());
      await tester.pumpAndSettle();

      // Should redirect to login
      expect(find.text('Masuk'), findsWidgets);
    });

    testWidgets('AC4: unauthenticated deep link to /home redirects to login',
        (tester) async {
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthUnauthenticated());
      final appRouter = AppRouter(authBloc: helper.mockAuthBloc);

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
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthUnauthenticated());
      final appRouter = AppRouter(authBloc: helper.mockAuthBloc);

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
