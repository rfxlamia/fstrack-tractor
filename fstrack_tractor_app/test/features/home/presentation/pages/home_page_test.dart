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

      expect(find.text('Selamat datang, Test User!'), findsOneWidget);
    });

    testWidgets('displays default name when not authenticated', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthUnauthenticated());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Selamat datang, User!'), findsOneWidget);
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

    testWidgets('displays agriculture icon', (tester) async {
      const user = UserEntity(
        id: '1',
        fullName: 'Test User',
        role: UserRole.operator,
        estateId: 'estate1',
        isFirstTime: false,
      );
      when(() => mockAuthBloc.state).thenReturn(const AuthSuccess(user: user));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.agriculture), findsOneWidget);
    });
  });
}
