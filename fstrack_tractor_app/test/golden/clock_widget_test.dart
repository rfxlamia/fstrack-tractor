import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/theme/app_theme.dart';
import 'package:fstrack_tractor/features/home/presentation/widgets/clock_widget.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  Widget createGoldenWidget({DateTime? testTime}) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: ClockWidget(testTime: testTime),
        ),
      ),
    );
  }

  group('ClockWidget Golden Tests', () {
    testGoldens('ClockWidget displays 14:30 WIB', (tester) async {
      // 14:30 WIB = 07:30 UTC
      final testTime = DateTime.utc(2026, 1, 13, 7, 30, 0);

      await tester.pumpWidgetBuilder(
        createGoldenWidget(testTime: testTime),
      );

      await screenMatchesGolden(tester, 'clock_widget_1430');
    });

    testGoldens('ClockWidget displays 09:05 WIB (single digit minute)',
        (tester) async {
      // 09:05 WIB = 02:05 UTC
      final testTime = DateTime.utc(2026, 1, 13, 2, 5, 0);

      await tester.pumpWidgetBuilder(
        createGoldenWidget(testTime: testTime),
      );

      await screenMatchesGolden(tester, 'clock_widget_0905');
    });
  });
}
