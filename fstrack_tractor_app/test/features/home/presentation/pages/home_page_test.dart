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
import 'package:fstrack_tractor/features/home/presentation/widgets/role_based_menu_cards.dart';
import 'package:mocktail/mocktail.dart';
import '../../../../helpers/home_page_test_helper.dart';

void main() {
  final helper = HomePageTestHelper();

  setUpAll(() => helper.setUpAll());

  setUp(() => helper.setUp());
  tearDown(() => helper.tearDown());
  tearDownAll(() => helper.tearDownAll());

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: AppTheme.light,
      home: BlocProvider<AuthBloc>.value(
        value: helper.mockAuthBloc,
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
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: user));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(weatherWidgetInitDelay);

      // Verify user name appears in greeting
      expect(find.textContaining('Test User'), findsOneWidget);
    });

    testWidgets('displays default name when not authenticated', (tester) async {
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthUnauthenticated());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(weatherWidgetInitDelay);

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
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: user));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(weatherWidgetInitDelay);

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
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: user));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(weatherWidgetInitDelay);

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
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: user));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(weatherWidgetInitDelay);

      await tester.tap(find.byIcon(Icons.logout));
      await tester.pump();

      verify(() => helper.mockAuthBloc.add(const LogoutRequested())).called(1);
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
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: testUser));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(weatherWidgetInitDelay);

      expect(find.byType(GreetingHeader), findsOneWidget);
    });

    testWidgets('displays ClockWidget', (tester) async {
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: testUser));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(weatherWidgetInitDelay);

      expect(find.byType(ClockWidget), findsOneWidget);
    });

    testWidgets('displays RoleBasedMenuCards - Story 3.4', (tester) async {
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: testUser));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(weatherWidgetInitDelay);

      // Check for RoleBasedMenuCards widget
      expect(find.byType(RoleBasedMenuCards), findsOneWidget);
    });

    testWidgets('layout has SafeArea and SingleChildScrollView', (tester) async {
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: testUser));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(weatherWidgetInitDelay);

      // HomePage should contain SafeArea (at least one)
      expect(find.byType(SafeArea), findsWidgets);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('layout has correct widget order', (tester) async {
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: testUser));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(weatherWidgetInitDelay);

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

  group('HomePage FAB Tests (Story 3.4 - AC6)', () {
    testWidgets('Kasie role shows FAB', (tester) async {
      const kasieUser = UserEntity(
        id: '1',
        fullName: 'Kasie User',
        role: UserRole.kasie,
        estateId: 'estate1',
        isFirstTime: false,
      );
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: kasieUser));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(weatherWidgetInitDelay);

      // Kasie should see FAB with Icons.add
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('Operator role does not show FAB', (tester) async {
      const operatorUser = UserEntity(
        id: '2',
        fullName: 'Operator User',
        role: UserRole.operator,
        estateId: 'estate1',
        isFirstTime: false,
      );
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: operatorUser));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(weatherWidgetInitDelay);

      // Operator should NOT see FAB
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('Mandor role does not show FAB', (tester) async {
      const mandorUser = UserEntity(
        id: '3',
        fullName: 'Mandor User',
        role: UserRole.mandor,
        estateId: 'estate1',
        isFirstTime: false,
      );
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: mandorUser));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(weatherWidgetInitDelay);

      // Mandor should NOT see FAB
      expect(find.byType(FloatingActionButton), findsNothing);
    });

    testWidgets('Admin role does not show FAB', (tester) async {
      const adminUser = UserEntity(
        id: '4',
        fullName: 'Admin User',
        role: UserRole.admin,
        estateId: 'estate1',
        isFirstTime: false,
      );
      when(() => helper.mockAuthBloc.state)
          .thenReturn(const AuthSuccess(user: adminUser));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump(weatherWidgetInitDelay);

      // Admin should NOT see FAB
      expect(find.byType(FloatingActionButton), findsNothing);
    });
  });
}
