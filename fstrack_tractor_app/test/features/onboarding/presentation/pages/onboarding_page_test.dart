import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/router/routes.dart';
import 'package:fstrack_tractor/core/theme/app_theme.dart';
import 'package:fstrack_tractor/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('OnboardingPage', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        initialLocation: Routes.onboarding,
        routes: [
          GoRoute(
            path: Routes.onboarding,
            builder: (context, state) => const OnboardingPage(),
          ),
          GoRoute(
            path: Routes.home,
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Home Page')),
            ),
          ),
        ],
      );
    });

    Widget createWidgetUnderTest() {
      return MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: router,
      );
    }

    testWidgets('displays welcome title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Selamat Datang'), findsOneWidget);
    });

    testWidgets('displays welcome message', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Selamat datang di FSTrack Tractor!'), findsOneWidget);
    });

    testWidgets('displays waving hand icon', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.waving_hand), findsOneWidget);
    });

    testWidgets('displays continue button', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Lanjutkan ke Home'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('continue button navigates to home', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Lanjutkan ke Home'));
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
    });

    testWidgets('displays placeholder text about Epic 5', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(
        find.textContaining('Onboarding lengkap akan tersedia di Epic 5'),
        findsOneWidget,
      );
    });
  });
}
