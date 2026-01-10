import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fstrack_tractor/core/router/app_router.dart';
import 'package:fstrack_tractor/core/theme/app_theme.dart';

void main() {
  group('FsTrackApp', () {
    testWidgets('renders MaterialApp.router with correct configuration',
        (WidgetTester tester) async {
      // Build app with router configuration
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

      // Verify initial route shows login placeholder
      expect(find.text('Login Page - Placeholder'), findsOneWidget);
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
      expect(find.text('Login Page - Placeholder'), findsOneWidget);
    });
  });
}
