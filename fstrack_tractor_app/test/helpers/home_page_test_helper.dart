import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fstrack_tractor/core/network/connectivity_checker.dart';
import 'package:fstrack_tractor/features/auth/domain/services/session_expiry_checker.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_event.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_state.dart';
import 'package:fstrack_tractor/features/home/presentation/bloc/first_time_hints_bloc.dart';
import 'package:fstrack_tractor/features/weather/presentation/bloc/weather_bloc.dart';
import 'package:fstrack_tractor/features/weather/presentation/bloc/weather_event.dart';
import 'package:fstrack_tractor/features/weather/presentation/bloc/weather_state.dart';
import 'package:fstrack_tractor/injection_container.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks/mock_connectivity_checker.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockWeatherBloc extends MockBloc<WeatherEvent, WeatherState>
    implements WeatherBloc {}

class MockFirstTimeHintsBloc
    extends MockBloc<FirstTimeHintsEvent, FirstTimeHintsState>
    implements FirstTimeHintsBloc {}

class MockSessionExpiryChecker extends Mock implements SessionExpiryChecker {}

// WeatherWidget has Timer.periodic that prevents pumpAndSettle() from settling.
// This delay allows initial build to complete before assertions.
const Duration weatherWidgetInitDelay = Duration(milliseconds: 100);

/// HomePageTestHelper - Centralized test setup for HomePage-related tests
///
/// MIGRATION GUIDE: See bottom of file for adding new dependencies
class HomePageTestHelper {
  HomePageTestHelper({this.registerAuthBlocInGetIt = false});

  final bool registerAuthBlocInGetIt;

  late MockAuthBloc mockAuthBloc;
  late MockWeatherBloc mockWeatherBloc;
  late MockFirstTimeHintsBloc mockFirstTimeHintsBloc;
  late MockConnectivityChecker mockConnectivityChecker;
  late MockSessionExpiryChecker mockSessionExpiryChecker;

  late StreamController<AuthState> authStreamController;
  late StreamController<WeatherState> weatherStreamController;
  late StreamController<FirstTimeHintsState> firstTimeHintsStreamController;

  void registerFallbackValues() {
    registerFallbackValue(const LoginRequested(username: '', password: ''));
    registerFallbackValue(const LogoutRequested());
    registerFallbackValue(const CheckAuthStatus());
    registerFallbackValue(const ClearError());
    registerFallbackValue(const SessionExpiryChecked());
    registerFallbackValue(const SessionWarningDismissed());
    registerFallbackValue(const LoadWeather());
    registerFallbackValue(const RefreshWeather());
    registerFallbackValue(const LoadCompletedTooltips());
    registerFallbackValue(const TooltipDismissed(''));
  }

  void setUpAll() {
    registerFallbackValues();
    getIt.allowReassignment = true;
  }

  void setUp() {
    mockAuthBloc = MockAuthBloc();
    mockWeatherBloc = MockWeatherBloc();
    mockFirstTimeHintsBloc = MockFirstTimeHintsBloc();
    mockConnectivityChecker = MockConnectivityChecker();
    mockSessionExpiryChecker = MockSessionExpiryChecker();

    authStreamController = StreamController<AuthState>.broadcast();
    weatherStreamController = StreamController<WeatherState>.broadcast();
    firstTimeHintsStreamController =
        StreamController<FirstTimeHintsState>.broadcast();

    _stubAuthBloc();
    _stubWeatherBloc();
    _stubFirstTimeHintsBloc();
    _stubSessionExpiryChecker();

    _registerInGetIt();
  }

  Future<void> tearDown() async {
    await authStreamController.close();
    await weatherStreamController.close();
    await firstTimeHintsStreamController.close();
    await mockAuthBloc.close();
    await mockWeatherBloc.close();
    await mockFirstTimeHintsBloc.close();
    mockConnectivityChecker.dispose();
    _unregisterFromGetIt();
  }

  void tearDownAll() {
    _unregisterFromGetIt();
    getIt.allowReassignment = false;
  }

  void _stubAuthBloc() {
    when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());
    when(() => mockAuthBloc.stream)
        .thenAnswer((_) => _authStreamWithInitial());
    when(() => mockAuthBloc.add(any())).thenReturn(null);
    when(() => mockAuthBloc.close()).thenAnswer((_) async {});
  }

  void _stubWeatherBloc() {
    when(() => mockWeatherBloc.state).thenReturn(const WeatherLoading());
    when(() => mockWeatherBloc.stream)
        .thenAnswer((_) => weatherStreamController.stream);
    when(() => mockWeatherBloc.add(any())).thenReturn(null);
    when(() => mockWeatherBloc.close()).thenAnswer((_) async {});
  }

  void _stubFirstTimeHintsBloc() {
    when(() => mockFirstTimeHintsBloc.state).thenReturn(
      const FirstTimeHintsState(
        completedTooltips: {'weather', 'menu_card'},
        currentTooltip: null,
      ),
    );
    when(() => mockFirstTimeHintsBloc.stream)
        .thenAnswer((_) => firstTimeHintsStreamController.stream);
    when(() => mockFirstTimeHintsBloc.add(any())).thenReturn(null);
    when(() => mockFirstTimeHintsBloc.close()).thenAnswer((_) async {});
  }

  void _stubSessionExpiryChecker() {
    when(() => mockSessionExpiryChecker.shouldShowWarning())
        .thenAnswer((_) async => false);
    when(() => mockSessionExpiryChecker.canShowWarningToday())
        .thenAnswer((_) async => true);
    when(() => mockSessionExpiryChecker.markWarningShown())
        .thenAnswer((_) async {});
    when(() => mockSessionExpiryChecker.getDaysUntilExpiry())
        .thenAnswer((_) async => 10);
  }

  Stream<AuthState> _authStreamWithInitial() async* {
    yield mockAuthBloc.state;
    yield* authStreamController.stream;
  }

  void _registerInGetIt() {
    if (getIt.isRegistered<AuthBloc>()) getIt.unregister<AuthBloc>();
    if (registerAuthBlocInGetIt) {
      getIt.registerSingleton<AuthBloc>(mockAuthBloc);
    }

    if (getIt.isRegistered<WeatherBloc>()) getIt.unregister<WeatherBloc>();
    getIt.registerSingleton<WeatherBloc>(mockWeatherBloc);

    if (getIt.isRegistered<FirstTimeHintsBloc>()) {
      getIt.unregister<FirstTimeHintsBloc>();
    }
    getIt.registerSingleton<FirstTimeHintsBloc>(mockFirstTimeHintsBloc);

    if (getIt.isRegistered<ConnectivityChecker>()) {
      getIt.unregister<ConnectivityChecker>();
    }
    getIt.registerSingleton<ConnectivityChecker>(mockConnectivityChecker);

    if (getIt.isRegistered<SessionExpiryChecker>()) {
      getIt.unregister<SessionExpiryChecker>();
    }
    getIt.registerSingleton<SessionExpiryChecker>(mockSessionExpiryChecker);
  }

  void _unregisterFromGetIt() {
    if (getIt.isRegistered<AuthBloc>()) getIt.unregister<AuthBloc>();
    if (getIt.isRegistered<WeatherBloc>()) getIt.unregister<WeatherBloc>();
    if (getIt.isRegistered<FirstTimeHintsBloc>()) {
      getIt.unregister<FirstTimeHintsBloc>();
    }
    if (getIt.isRegistered<ConnectivityChecker>()) {
      getIt.unregister<ConnectivityChecker>();
    }
    if (getIt.isRegistered<SessionExpiryChecker>()) {
      getIt.unregister<SessionExpiryChecker>();
    }
  }
}

/// MIGRATION GUIDE
/// ================
/// When HomePage adds a new BLoC dependency:
///
/// 1. Add mock class:
///    class MockNewBloc extends MockBloc<NewEvent, NewState> implements NewBloc {}
///
/// 2. Add public field:
///    late MockNewBloc mockNewBloc;
///
/// 3. Add stream controller if needed:
///    late StreamController<NewState> newStreamController;
///
/// 4. Add fallback value in registerFallbackValues():
///    registerFallbackValue(const SomeNewEvent());
///
/// 5. Initialize in setUp():
///    mockNewBloc = MockNewBloc();
///    newStreamController = StreamController<NewState>.broadcast();
///
/// 6. Add _stubNewBloc() method and call it in setUp()
///
/// 7. Register in _registerInGetIt():
///    if (getIt.isRegistered<NewBloc>()) getIt.unregister<NewBloc>();
///    getIt.registerSingleton<NewBloc>(mockNewBloc);
///
/// 8. Cleanup in tearDown():
///    await newStreamController.close();
///    await mockNewBloc.close();
///
/// 9. Unregister in _unregisterFromGetIt():
///    if (getIt.isRegistered<NewBloc>()) getIt.unregister<NewBloc>();
///
/// That's it! All test files using this helper will automatically work.
