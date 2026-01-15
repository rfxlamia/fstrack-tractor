import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/constants/ui_strings.dart';
import 'package:fstrack_tractor/core/widgets/animated_banner.dart';
import 'package:fstrack_tractor/core/widgets/banner_wrapper.dart';
import 'package:fstrack_tractor/core/widgets/offline_banner.dart';
import 'package:fstrack_tractor/features/auth/domain/services/session_expiry_checker.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_event.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_state.dart';
import 'package:fstrack_tractor/features/auth/presentation/widgets/session_warning_banner.dart';
import 'package:fstrack_tractor/features/weather/presentation/bloc/weather_bloc.dart';
import 'package:fstrack_tractor/features/weather/presentation/bloc/weather_event.dart';
import 'package:fstrack_tractor/features/weather/presentation/bloc/weather_state.dart';
import '../../mocks/mock_connectivity_checker.dart';
import 'package:mocktail/mocktail.dart';

class MockWeatherBloc extends MockBloc<WeatherEvent, WeatherState>
    implements WeatherBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockSessionExpiryChecker extends Mock implements SessionExpiryChecker {}

void main() {
  late MockWeatherBloc mockWeatherBloc;
  late MockConnectivityChecker mockConnectivityChecker;
  late MockSessionExpiryChecker mockSessionExpiryChecker;
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(const RefreshWeather());
    registerFallbackValue(const SessionExpiryChecked());
  });

  setUp(() {
    mockWeatherBloc = MockWeatherBloc();
    mockConnectivityChecker = MockConnectivityChecker();
    mockSessionExpiryChecker = MockSessionExpiryChecker();
    mockAuthBloc = MockAuthBloc();

    when(() => mockWeatherBloc.state).thenReturn(const WeatherLoading());
    when(() => mockWeatherBloc.stream)
        .thenAnswer((_) => const Stream<WeatherState>.empty());
    when(() => mockWeatherBloc.add(any())).thenReturn(null);
    when(() => mockWeatherBloc.close()).thenAnswer((_) async {});

    // Mock AuthBloc
    when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
    when(() => mockAuthBloc.stream)
        .thenAnswer((_) => const Stream<AuthState>.empty());
    when(() => mockAuthBloc.add(any())).thenReturn(null);

    // Default mocks for SessionExpiryChecker
    when(() => mockSessionExpiryChecker.shouldShowWarning())
        .thenAnswer((_) async => false);
    when(() => mockSessionExpiryChecker.canShowWarningToday())
        .thenAnswer((_) async => true);
    when(() => mockSessionExpiryChecker.markWarningShown())
        .thenAnswer((_) async {});
    when(() => mockSessionExpiryChecker.getDaysUntilExpiry())
        .thenAnswer((_) async => 2);
  });

  tearDown(() async {
    await mockWeatherBloc.close();
    mockConnectivityChecker.dispose();
  });

  Widget buildTestWidget() {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<WeatherBloc>.value(value: mockWeatherBloc),
          BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        ],
        child: Scaffold(
          body: BannerWrapper(
            connectivityChecker: mockConnectivityChecker,
            sessionExpiryChecker: mockSessionExpiryChecker,
            child: const Text('Content'),
          ),
        ),
      ),
    );
  }

  testWidgets('shows offline banner when app starts offline', (tester) async {
    mockConnectivityChecker.setOnline(false);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final banner = tester.widget<OfflineBanner>(find.byType(OfflineBanner));
    expect(banner.isVisible, isTrue);
  });

  testWidgets('hides banner when online and shows on connectivity changes',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(tester.widget<OfflineBanner>(find.byType(OfflineBanner)).isVisible,
        isFalse);

    mockConnectivityChecker.setOnline(false);
    await tester.pumpAndSettle();

    expect(tester.widget<OfflineBanner>(find.byType(OfflineBanner)).isVisible,
        isTrue);

    mockConnectivityChecker.setOnline(true);
    await tester.pumpAndSettle();

    expect(tester.widget<OfflineBanner>(find.byType(OfflineBanner)).isVisible,
        isFalse);
  });

  testWidgets('applies animation settings for banner transitions',
      (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    final animatedBanner = tester.widget<AnimatedBanner>(
      find.byType(AnimatedBanner).first,
    );

    expect(animatedBanner.duration, const Duration(milliseconds: 300));
    expect(animatedBanner.curve, Curves.easeOut);
  });

  testWidgets('tap triggers refresh and shows snackbar', (tester) async {
    mockConnectivityChecker.setOnline(false);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(OfflineBanner));
    await tester.pump();

    verify(() => mockWeatherBloc.add(const RefreshWeather())).called(1);
    expect(find.text(UIStrings.offlineRetryMessage), findsOneWidget);
  });

  testWidgets('shows session warning when criteria met', (tester) async {
    when(() => mockSessionExpiryChecker.shouldShowWarning())
        .thenAnswer((_) async => true);
    when(() => mockSessionExpiryChecker.canShowWarningToday())
        .thenAnswer((_) async => true);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(SessionWarningBanner), findsOneWidget);
  });

  testWidgets('hides session warning when dismissed and marks shown',
      (tester) async {
    when(() => mockSessionExpiryChecker.shouldShowWarning())
        .thenAnswer((_) async => true);
    when(() => mockSessionExpiryChecker.canShowWarningToday())
        .thenAnswer((_) async => true);

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    expect(find.byType(SessionWarningBanner), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    verify(() => mockSessionExpiryChecker.markWarningShown()).called(1);
    expect(find.byType(SessionWarningBanner).hitTestable(), findsNothing);
  });
}
