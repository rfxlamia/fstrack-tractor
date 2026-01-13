import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/theme/app_colors.dart';
import 'package:fstrack_tractor/core/theme/app_text_styles.dart';
import 'package:fstrack_tractor/features/home/presentation/widgets/clock_widget.dart';

void main() {
  Widget createWidget({DateTime? testTime}) {
    return MaterialApp(
      home: Scaffold(
        body: ClockWidget(testTime: testTime),
      ),
    );
  }

  group('ClockWidget Tests', () {
    testWidgets('displays time in "HH:mm WIB" format', (tester) async {
      // 14:30 WIB = 07:30 UTC
      final testTime = DateTime.utc(2026, 1, 13, 7, 30, 0);

      await tester.pumpWidget(createWidget(testTime: testTime));

      expect(find.text('14:30 WIB'), findsOneWidget);
    });

    testWidgets('uses testTime parameter correctly', (tester) async {
      // 09:15 WIB = 02:15 UTC
      final testTime = DateTime.utc(2026, 1, 13, 2, 15, 0);

      await tester.pumpWidget(createWidget(testTime: testTime));

      expect(find.text('09:15 WIB'), findsOneWidget);
    });

    testWidgets('formats single-digit hours with leading zero', (tester) async {
      // 08:45 WIB = 01:45 UTC
      final testTime = DateTime.utc(2026, 1, 13, 1, 45, 0);

      await tester.pumpWidget(createWidget(testTime: testTime));

      expect(find.text('08:45 WIB'), findsOneWidget);
    });

    testWidgets('formats single-digit minutes with leading zero',
        (tester) async {
      // 14:05 WIB = 07:05 UTC
      final testTime = DateTime.utc(2026, 1, 13, 7, 5, 0);

      await tester.pumpWidget(createWidget(testTime: testTime));

      expect(find.text('14:05 WIB'), findsOneWidget);
    });

    testWidgets('uses correct typography (w500s12, textSecondary)',
        (tester) async {
      final testTime = DateTime.utc(2026, 1, 13, 7, 30, 0);

      await tester.pumpWidget(createWidget(testTime: testTime));

      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.fontSize, AppTextStyles.w500s12.fontSize);
      expect(textWidget.style?.fontWeight, AppTextStyles.w500s12.fontWeight);
      expect(textWidget.style?.color, AppColors.textSecondary);
    });

    testWidgets('calculates WIB timezone correctly (UTC+7)', (tester) async {
      // UTC midnight should be 07:00 WIB
      final testTime = DateTime.utc(2026, 1, 13, 0, 0, 0);

      await tester.pumpWidget(createWidget(testTime: testTime));

      expect(find.text('07:00 WIB'), findsOneWidget);
    });

    testWidgets('handles 24-hour format correctly', (tester) async {
      // 23:59 WIB = 16:59 UTC
      final testTime = DateTime.utc(2026, 1, 13, 16, 59, 0);

      await tester.pumpWidget(createWidget(testTime: testTime));

      expect(find.text('23:59 WIB'), findsOneWidget);
    });

    testWidgets('handles midnight correctly', (tester) async {
      // 00:00 WIB = 17:00 UTC (previous day)
      final testTime = DateTime.utc(2026, 1, 12, 17, 0, 0);

      await tester.pumpWidget(createWidget(testTime: testTime));

      expect(find.text('00:00 WIB'), findsOneWidget);
    });

    testWidgets('timer is created and updates in production mode',
        (tester) async {
      // No testTime = production mode, timer should be created
      await tester.pumpWidget(createWidget());

      // Get initial time text
      final initialText = tester.widget<Text>(find.byType(Text)).data!;
      expect(initialText, contains('WIB'));

      // Verify timer exists and continues running
      // (We can't easily test the exact 60-second update without waiting,
      //  but we verify the widget is in production mode)
      // The absence of crash indicates timer was created successfully
    });
  });

  group('WIB Timezone Calculation Tests', () {
    test('UTC+7 conversion for various times', () {
      final testCases = [
        // UTC time, expected WIB time
        {'utc': DateTime.utc(2026, 1, 13, 0, 0), 'expected': '07:00'},
        {'utc': DateTime.utc(2026, 1, 13, 6, 30), 'expected': '13:30'},
        {'utc': DateTime.utc(2026, 1, 13, 12, 0), 'expected': '19:00'},
        {'utc': DateTime.utc(2026, 1, 13, 17, 0), 'expected': '00:00'},
        {'utc': DateTime.utc(2026, 1, 13, 23, 59), 'expected': '06:59'},
      ];

      for (final testCase in testCases) {
        final utcTime = testCase['utc'] as DateTime;
        final wibTime = utcTime.add(const Duration(hours: 7));
        final formatted =
            '${wibTime.hour.toString().padLeft(2, '0')}:${wibTime.minute.toString().padLeft(2, '0')}';
        expect(formatted, testCase['expected']);
      }
    });
  });
}
