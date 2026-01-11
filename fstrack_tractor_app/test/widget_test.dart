import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:fstrack_tractor/core/router/app_router.dart';
import 'package:fstrack_tractor/core/router/routes.dart';
import 'package:fstrack_tractor/core/theme/app_theme.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fstrack_tractor/features/auth/presentation/bloc/auth_state.dart';
import 'package:fstrack_tractor/features/auth/presentation/pages/login_form.dart';
import 'package:fstrack_tractor/injection_container.dart';

import 'widget_test.mocks.dart';

@GenerateMocks([AuthBloc])
void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(mockAuthBloc.state).thenReturn(const AuthInitial());
    when(mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());

    // Reset and register mock in getIt
    if (getIt.isRegistered<AuthBloc>()) {
      getIt.unregister<AuthBloc>();
    }
    getIt.registerSingleton<AuthBloc>(mockAuthBloc);
  });

  tearDown(() {
    if (getIt.isRegistered<AuthBloc>()) {
      getIt.unregister<AuthBloc>();
    }
  });

  group('FsTrackApp', () {
    testWidgets('renders MaterialApp.router with correct configuration',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          title: 'FSTrack Tractor',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: appRouter,
        ),
      );

      // Verify app renders without errors
      expect(find.byType(MaterialApp), findsOneWidget);

      // Verify login page is shown with actual UI (not placeholder)
      expect(find.text('Masuk'), findsOneWidget);
    });

    testWidgets('uses correct theme colors', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          title: 'FSTrack Tractor',
          theme: AppTheme.light,
          routerConfig: appRouter,
        ),
      );

      // Verify theme is applied
      final MaterialApp app = tester.widget(find.byType(MaterialApp));
      expect(app.theme?.primaryColor, const Color(0xFF008945));
    });
  });

  group('AppRouter', () {
    testWidgets('initial route is login', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: appRouter,
        ),
      );

      // Verify login page is shown as initial route
      expect(find.byType(LoginForm), findsOneWidget);
      expect(find.text('Masuk'), findsOneWidget);
    });

    test('routes are correctly defined', () {
      expect(Routes.login, '/login');
      expect(Routes.home, '/home');
    });
  });
}
