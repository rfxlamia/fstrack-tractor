import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/router/routes.dart';
import 'package:fstrack_tractor/core/theme/app_theme.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_state.dart';
import 'package:fstrack_tractor/features/auth/presentation/pages/login_form.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
    when(() => mockAuthBloc.stream)
        .thenAnswer((_) => Stream.value(const AuthInitial()));
  });

  group('FsTrackApp', () {
    testWidgets('renders MaterialApp with correct configuration',
        (WidgetTester tester) async {
      // Build app with LoginForm directly (bypassing getIt in LoginPage)
      await tester.pumpWidget(
        MaterialApp(
          title: 'FSTrack Tractor',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: BlocProvider<AuthBloc>.value(
                value: mockAuthBloc,
                child: const LoginForm(),
              ),
            ),
          ),
        ),
      );

      // Verify app renders without errors
      expect(find.byType(MaterialApp), findsOneWidget);

      // Verify login form is shown with actual UI (not placeholder)
      expect(find.text('Masuk'), findsWidgets);
    });

    testWidgets('uses correct theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          title: 'FSTrack Tractor',
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: BlocProvider<AuthBloc>.value(
                value: mockAuthBloc,
                child: const LoginForm(),
              ),
            ),
          ),
        ),
      );

      // Verify theme is applied
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.primaryColor, const Color(0xFF008945));
    });
  });

  group('AppRouter', () {
    testWidgets('LoginForm renders correctly as initial screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: BlocProvider<AuthBloc>.value(
                value: mockAuthBloc,
                child: const LoginForm(),
              ),
            ),
          ),
        ),
      );

      // Verify login form is shown
      expect(find.text('Masuk'), findsWidgets);
      expect(find.text('Silakan masuk untuk melanjutkan'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    test('routes are correctly defined', () {
      expect(Routes.login, '/login');
      expect(Routes.home, '/home');
    });
  });
}
