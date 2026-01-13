import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/theme/app_theme.dart';
import 'package:fstrack_tractor/features/auth/domain/entities/user_entity.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_event.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_state.dart';
import 'package:fstrack_tractor/features/home/presentation/pages/home_page.dart';
import 'package:fstrack_tractor/features/home/presentation/widgets/clock_widget.dart';
import 'package:fstrack_tractor/features/home/presentation/widgets/greeting_header.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: AppTheme.light,
      home: BlocProvider<AuthBloc>.value(
        value: mockAuthBloc,
        child: const HomePage(),
      ),
    );
  }

  group('HomePage', () {
    testWidgets('displays user name when authenticated', (tester) async {
      const user = UserEntity(
        id: '1',
        fullName: 'Test User',
        role: UserRole.operator,
        estateId: 'estate1',
        isFirstTime: false,
      );
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: user));

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify user name appears in greeting
      expect(find.textContaining('Test User'), findsOneWidget);
    });

    testWidgets('displays default name when not authenticated', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());

      await tester.pumpWidget(createWidgetUnderTest());

      // Fallback to 'User'
      expect(find.textContaining('User'), findsOneWidget);
    });

    testWidgets('displays app bar with title', (tester) async {
      const user = UserEntity(
        id: '1',
        fullName: 'Test User',
        role: UserRole.operator,
        estateId: 'estate1',
        isFirstTime: false,
      );
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: user));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('FSTrack Tractor'), findsOneWidget);
    });

    testWidgets('displays logout button in app bar', (tester) async {
      const user = UserEntity(
        id: '1',
        fullName: 'Test User',
        role: UserRole.operator,
        estateId: 'estate1',
        isFirstTime: false,
      );
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: user));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('logout button dispatches LogoutRequested event',
        (tester) async {
      const user = UserEntity(
        id: '1',
        fullName: 'Test User',
        role: UserRole.operator,
        estateId: 'estate1',
        isFirstTime: false,
      );
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: user));

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pump();

      verify(() => mockAuthBloc.add(const LogoutRequested())).called(1);
    });
  });

  group('HomePage Layout Tests (Story 3.1)', () {
    const testUser = UserEntity(
      id: '1',
      fullName: 'Test User',
      role: UserRole.operator,
      estateId: 'estate1',
      isFirstTime: false,
    );

    testWidgets('displays GreetingHeader widget', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: testUser));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(GreetingHeader), findsOneWidget);
    });

    testWidgets('displays ClockWidget', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: testUser));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(ClockWidget), findsOneWidget);
    });

    testWidgets('displays placeholder containers', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: testUser));

      await tester.pumpWidget(createWidgetUnderTest());

      // Check for placeholder texts
      expect(find.text('Weather Widget'), findsOneWidget);
      expect(find.text('Akan ditambahkan di Story 3.3'), findsOneWidget);
      expect(find.text('Menu Cards'), findsOneWidget);
      expect(find.text('Akan ditambahkan di Story 3.4'), findsOneWidget);
    });

    testWidgets('layout has SafeArea and SingleChildScrollView', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: testUser));

      await tester.pumpWidget(createWidgetUnderTest());

      // HomePage should contain SafeArea (at least one)
      expect(find.byType(SafeArea), findsWidgets);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('layout has correct widget order', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: testUser));

      await tester.pumpWidget(createWidgetUnderTest());

      // Verify GreetingHeader appears before ClockWidget
      final greetingFinder = find.byType(GreetingHeader);
      final clockFinder = find.byType(ClockWidget);

      expect(greetingFinder, findsOneWidget);
      expect(clockFinder, findsOneWidget);

      // Get widget positions
      final greetingPos = tester.getTopLeft(greetingFinder);
      final clockPos = tester.getTopLeft(clockFinder);

      // GreetingHeader should be above ClockWidget
      expect(greetingPos.dy < clockPos.dy, true);
    });
  });
}
