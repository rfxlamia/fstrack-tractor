import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/router/app_router.dart';
import 'package:fstrack_tractor/core/network/connectivity_checker.dart';
import 'package:fstrack_tractor/core/theme/app_theme.dart';
import 'package:fstrack_tractor/features/auth/domain/entities/user_entity.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_event.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_state.dart';
import 'package:fstrack_tractor/features/home/presentation/widgets/greeting_header.dart';
import 'package:fstrack_tractor/injection_container.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fstrack_tractor/features/weather/presentation/bloc/weather_bloc.dart';
import 'package:fstrack_tractor/features/weather/presentation/bloc/weather_event.dart';
import 'package:fstrack_tractor/features/weather/presentation/bloc/weather_state.dart';
import 'package:fstrack_tractor/features/auth/domain/services/session_expiry_checker.dart';
import '../../mocks/mock_connectivity_checker.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockWeatherBloc extends MockBloc<WeatherEvent, WeatherState>
    implements WeatherBloc {}

class MockSessionExpiryChecker extends Mock implements SessionExpiryChecker {}

// WeatherWidget has Timer.periodic that prevents pumpAndSettle() from settling.
// This delay allows initial build to complete before assertions.
const Duration _weatherWidgetInitDelay = Duration(milliseconds: 100);

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockWeatherBloc mockWeatherBloc;
  late MockConnectivityChecker mockConnectivityChecker;
  late MockSessionExpiryChecker mockSessionExpiryChecker;
  late StreamController<AuthState> authStreamController;
  late StreamController<WeatherState> weatherStreamController;

  setUpAll(() {
    registerFallbackValue(const LoginRequested(username: '', password: ''));
    registerFallbackValue(const LoadWeather());
    registerFallbackValue(const SessionExpiryChecked());
    // Allow reassignment for tests
    getIt.allowReassignment = true;
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    authStreamController = StreamController<AuthState>.broadcast();
    when(() => mockAuthBloc.stream).thenAnswer((_) => authStreamController.stream);
    // Stub AuthBloc add() for any events
    when(() => mockAuthBloc.add(any())).thenReturn(null);

    // Register mock AuthBloc in GetIt so LoginPage can find it
    if (getIt.isRegistered<AuthBloc>()) {
      getIt.unregister<AuthBloc>();
    }
    getIt.registerSingleton<AuthBloc>(mockAuthBloc);

    mockWeatherBloc = MockWeatherBloc();
    mockConnectivityChecker = MockConnectivityChecker();
    mockSessionExpiryChecker = MockSessionExpiryChecker();
    weatherStreamController = StreamController<WeatherState>.broadcast();
    when(() => mockWeatherBloc.state).thenReturn(const WeatherLoading());
    when(() => mockWeatherBloc.stream).thenAnswer((_) => weatherStreamController.stream);
    // Stub add() to prevent actual event processing
    when(() => mockWeatherBloc.add(any())).thenReturn(null);
    // Stub close() for proper cleanup
    when(() => mockWeatherBloc.close()).thenAnswer((_) async {});

    // Stub SessionExpiryChecker
    when(() => mockSessionExpiryChecker.shouldShowWarning())
        .thenAnswer((_) async => false);
    when(() => mockSessionExpiryChecker.canShowWarningToday())
        .thenAnswer((_) async => true);
    when(() => mockSessionExpiryChecker.markWarningShown())
        .thenAnswer((_) async {});
    when(() => mockSessionExpiryChecker.getDaysUntilExpiry())
        .thenAnswer((_) async => 10);

    if (getIt.isRegistered<WeatherBloc>()) {
      getIt.unregister<WeatherBloc>();
    }
    getIt.registerSingleton<WeatherBloc>(mockWeatherBloc);

    if (getIt.isRegistered<ConnectivityChecker>()) {
      getIt.unregister<ConnectivityChecker>();
    }
    getIt.registerSingleton<ConnectivityChecker>(mockConnectivityChecker);

    if (getIt.isRegistered<SessionExpiryChecker>()) {
      getIt.unregister<SessionExpiryChecker>();
    }
    getIt.registerSingleton<SessionExpiryChecker>(mockSessionExpiryChecker);
  });

  tearDown(() async {
    await authStreamController.close();
    await weatherStreamController.close();
    await mockAuthBloc.close();
    await mockWeatherBloc.close();
    mockConnectivityChecker.dispose();
  });

  tearDownAll(() {
    if (getIt.isRegistered<AuthBloc>()) {
      getIt.unregister<AuthBloc>();
    }
    if (getIt.isRegistered<WeatherBloc>()) {
      getIt.unregister<WeatherBloc>();
    }
    if (getIt.isRegistered<ConnectivityChecker>()) {
      getIt.unregister<ConnectivityChecker>();
    }
    if (getIt.isRegistered<SessionExpiryChecker>()) {
      getIt.unregister<SessionExpiryChecker>();
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
      // Use pump() instead of pumpAndSettle() due to Timer in WeatherWidget
      await tester.pump();
      await tester.pump(_weatherWidgetInitDelay);

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
      // Use pump() instead of pumpAndSettle() due to Timer in WeatherWidget
      await tester.pump();
      await tester.pump(_weatherWidgetInitDelay);

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
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: user));
      final appRouter = AppRouter(authBloc: mockAuthBloc);

      await tester.pumpWidget(createApp(appRouter));
      // Use pump() instead of pumpAndSettle() due to Timer in WeatherWidget
      await tester.pump();
      await tester.pump(_weatherWidgetInitDelay);

      // Should be on home
      expect(find.text('FSTrack Tractor'), findsOneWidget);

      // Simulate logout by changing state and notifying router
      when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
      authStreamController.add(const AuthUnauthenticated());
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
