import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fstrack_tractor/features/auth/domain/entities/user_entity.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_event.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_state.dart';
import 'package:fstrack_tractor/features/home/presentation/bloc/first_time_hints_bloc.dart';
import 'package:fstrack_tractor/features/home/presentation/widgets/first_time_hints_wrapper.dart';
import 'package:get_it/get_it.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class MockFirstTimeHintsBloc
    extends MockBloc<FirstTimeHintsEvent, FirstTimeHintsState>
    implements FirstTimeHintsBloc {}

class FakeLoginRequested extends Fake implements LoginRequested {}

class FakeFirstTimeHintsEvent extends Fake implements FirstTimeHintsEvent {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockFirstTimeHintsBloc mockFirstTimeHintsBloc;

  setUpAll(() {
    registerFallbackValue(FakeLoginRequested());
    registerFallbackValue(FakeFirstTimeHintsEvent());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    mockFirstTimeHintsBloc = MockFirstTimeHintsBloc();

    // Reset GetIt and register mock
    if (GetIt.I.isRegistered<FirstTimeHintsBloc>()) {
      GetIt.I.unregister<FirstTimeHintsBloc>();
    }
    GetIt.I.registerSingleton<FirstTimeHintsBloc>(mockFirstTimeHintsBloc);
  });

  tearDown(() {
    if (GetIt.I.isRegistered<FirstTimeHintsBloc>()) {
      GetIt.I.unregister<FirstTimeHintsBloc>();
    }
  });

  UserEntity createTestUser({bool isFirstTime = false}) {
    return UserEntity(
      id: '1',
      fullName: 'Test User',
      role: UserRole.operator,
      estateId: 'estate-1',
      isFirstTime: isFirstTime,
    );
  }

  Widget buildTestWidget({required Widget child}) {
    return MaterialApp(
      home: Scaffold(
        body: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: child,
        ),
      ),
    );
  }

  group('FirstTimeHintsWrapper', () {
    testWidgets('renders child when user is not first-time', (tester) async {
      final user = createTestUser(isFirstTime: false);

      when(() => mockAuthBloc.state).thenReturn(AuthSuccess(user: user));
      when(() => mockFirstTimeHintsBloc.state)
          .thenReturn(const FirstTimeHintsState());

      await tester.pumpWidget(
        buildTestWidget(
          child: FirstTimeHintsWrapper(
            weatherWidgetKey: GlobalKey(),
            menuCardKey: GlobalKey(),
            child: const Text('Home Content'),
          ),
        ),
      );

      expect(find.text('Home Content'), findsOneWidget);
    });

    testWidgets('renders child when auth state is not AuthSuccess',
        (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
      when(() => mockFirstTimeHintsBloc.state)
          .thenReturn(const FirstTimeHintsState());

      await tester.pumpWidget(
        buildTestWidget(
          child: FirstTimeHintsWrapper(
            weatherWidgetKey: GlobalKey(),
            menuCardKey: GlobalKey(),
            child: const Text('Home Content'),
          ),
        ),
      );

      expect(find.text('Home Content'), findsOneWidget);
    });

    testWidgets('renders child when all tooltips are completed',
        (tester) async {
      final user = createTestUser(isFirstTime: true);

      when(() => mockAuthBloc.state).thenReturn(AuthSuccess(user: user));
      when(() => mockFirstTimeHintsBloc.state).thenReturn(
        const FirstTimeHintsState(
          completedTooltips: {'weather', 'menu_card'},
          currentTooltip: null,
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: FirstTimeHintsWrapper(
            weatherWidgetKey: GlobalKey(),
            menuCardKey: GlobalKey(),
            child: const Text('Home Content'),
          ),
        ),
      );

      expect(find.text('Home Content'), findsOneWidget);
    });

    testWidgets('shows tooltip overlay for first-time user', (tester) async {
      final user = createTestUser(isFirstTime: true);

      when(() => mockAuthBloc.state).thenReturn(AuthSuccess(user: user));
      when(() => mockFirstTimeHintsBloc.state).thenReturn(
        const FirstTimeHintsState(
          completedTooltips: {},
          currentTooltip: 'weather',
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: FirstTimeHintsWrapper(
            weatherWidgetKey: GlobalKey(),
            menuCardKey: GlobalKey(),
            child: const Text('Home Content'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show weather tooltip message
      expect(
        find.text(
            'Lihat prakiraan cuaca untuk merencanakan aktivitas lapangan'),
        findsOneWidget,
      );
    });

    testWidgets('shows menu_card tooltip after weather is completed',
        (tester) async {
      final user = createTestUser(isFirstTime: true);

      when(() => mockAuthBloc.state).thenReturn(AuthSuccess(user: user));
      when(() => mockFirstTimeHintsBloc.state).thenReturn(
        const FirstTimeHintsState(
          completedTooltips: {'weather'},
          currentTooltip: 'menu_card',
        ),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: FirstTimeHintsWrapper(
            weatherWidgetKey: GlobalKey(),
            menuCardKey: GlobalKey(),
            child: const Text('Home Content'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show menu_card tooltip message
      expect(
        find.text('Tap untuk melihat rencana kerja Anda'),
        findsOneWidget,
      );
    });

    testWidgets('dispatches LoadCompletedTooltips on init', (tester) async {
      final user = createTestUser(isFirstTime: true);

      when(() => mockAuthBloc.state).thenReturn(AuthSuccess(user: user));
      when(() => mockFirstTimeHintsBloc.state).thenReturn(
        const FirstTimeHintsState(currentTooltip: 'weather'),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: FirstTimeHintsWrapper(
            weatherWidgetKey: GlobalKey(),
            menuCardKey: GlobalKey(),
            child: const Text('Home Content'),
          ),
        ),
      );

      verify(() => mockFirstTimeHintsBloc.add(const LoadCompletedTooltips()))
          .called(1);
    });
  });

  group('FirstTimeHintsState', () {
    test('isAllCompleted returns true when currentTooltip is null', () {
      const state = FirstTimeHintsState(currentTooltip: null);
      expect(state.isAllCompleted, isTrue);
    });

    test('isAllCompleted returns false when currentTooltip is set', () {
      const state = FirstTimeHintsState(currentTooltip: 'weather');
      expect(state.isAllCompleted, isFalse);
    });

    test('equality works correctly', () {
      const state1 = FirstTimeHintsState(
        completedTooltips: {'weather'},
        currentTooltip: 'menu_card',
      );
      const state2 = FirstTimeHintsState(
        completedTooltips: {'weather'},
        currentTooltip: 'menu_card',
      );
      expect(state1, equals(state2));
    });
  });
}
