import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/features/auth/presentation/widgets/session_warning_banner.dart';
import 'package:fstrack_tractor/core/theme/app_colors.dart';
import 'package:fstrack_tractor/core/constants/ui_strings.dart';

void main() {
  testWidgets('SessionWarningBanner renders correctly',
      (WidgetTester tester) async {
    int daysRemaining = 2;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SessionWarningBanner(
            daysRemaining: daysRemaining,
            onDismiss: () {},
          ),
        ),
      ),
    );

    expect(find.byType(SessionWarningBanner), findsOneWidget);
    expect(find.byIcon(Icons.access_time), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
    expect(
        find.text(
            UIStrings.sessionExpiringBannerText.replaceAll('{days}', '2')),
        findsOneWidget);

    // Check background color (searching for Container with that color)
    final containerFinder = find.descendant(
      of: find.byType(SessionWarningBanner),
      matching: find.byWidgetPredicate((widget) =>
          widget is Container && widget.color == AppColors.bannerWarning),
    );
    expect(containerFinder, findsOneWidget);

    final size = tester.getSize(find.byType(SessionWarningBanner));
    expect(size.height, 56.0);
  });

  testWidgets('SessionWarningBanner calls onDismiss when close icon is tapped',
      (WidgetTester tester) async {
    bool dismissed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SessionWarningBanner(
            daysRemaining: 1,
            onDismiss: () {
              dismissed = true;
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.close));
    await tester.pump();

    expect(dismissed, true);
  });
}
