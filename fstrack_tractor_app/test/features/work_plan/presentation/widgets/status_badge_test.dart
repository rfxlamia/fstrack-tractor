import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/theme/app_colors.dart';
import 'package:fstrack_tractor/core/theme/app_theme.dart';
import 'package:fstrack_tractor/features/work_plan/presentation/widgets/status_badge.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import '../../../../fixtures/work_plan_fixtures.dart';

void main() {
  Widget createGoldenWidget({required Widget body}) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(child: body),
      ),
    );
  }

  group('StatusBadge', () {
    testWidgets('displays correct text for OPEN status', (tester) async {
      final workPlan = WorkPlanFixtures.openWorkPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(workPlan: workPlan),
          ),
        ),
      );

      expect(find.text('Terbuka'), findsOneWidget);
    });

    testWidgets('displays correct text for CLOSED status', (tester) async {
      final workPlan = WorkPlanFixtures.closedWorkPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(workPlan: workPlan),
          ),
        ),
      );

      expect(find.text('Ditugaskan'), findsOneWidget);
    });

    testWidgets('displays correct text for CANCEL status', (tester) async {
      final workPlan = WorkPlanFixtures.cancelledWorkPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(workPlan: workPlan),
          ),
        ),
      );

      expect(find.text('Dibatalkan'), findsOneWidget);
    });

    testWidgets('uses correct background color for OPEN status', (tester) async {
      final workPlan = WorkPlanFixtures.openWorkPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(workPlan: workPlan),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, AppColors.buttonOrange);
    });

    testWidgets('uses correct background color for CLOSED status', (tester) async {
      final workPlan = WorkPlanFixtures.closedWorkPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(workPlan: workPlan),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, AppColors.buttonBlue);
    });

    testWidgets('uses correct background color for CANCEL status', (tester) async {
      final workPlan = WorkPlanFixtures.cancelledWorkPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(workPlan: workPlan),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, AppColors.error);
    });

    testWidgets('displays unknown status as-is', (tester) async {
      final workPlan = WorkPlanFixtures.openWorkPlan().copyWith(status: 'UNKNOWN');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(workPlan: workPlan),
          ),
        ),
      );

      expect(find.text('UNKNOWN'), findsOneWidget);
    });

    testWidgets('has white text color', (tester) async {
      final workPlan = WorkPlanFixtures.openWorkPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(workPlan: workPlan),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      final style = text.style;

      expect(style?.color, Colors.white);
    });

    testWidgets('has correct border radius', (tester) async {
      final workPlan = WorkPlanFixtures.openWorkPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge(workPlan: workPlan),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.borderRadius, BorderRadius.circular(8));
    });
  });

  group('StatusBadge Golden Tests', () {
    testGoldens('renders OPEN status correctly', (tester) async {
      final workPlan = WorkPlanFixtures.openWorkPlan();

      await tester.pumpWidgetBuilder(
        createGoldenWidget(body: StatusBadge(workPlan: workPlan)),
      );
      await screenMatchesGolden(tester, 'status_badge_open');
    });

    testGoldens('renders CLOSED status correctly', (tester) async {
      final workPlan = WorkPlanFixtures.closedWorkPlan();

      await tester.pumpWidgetBuilder(
        createGoldenWidget(body: StatusBadge(workPlan: workPlan)),
      );
      await screenMatchesGolden(tester, 'status_badge_closed');
    });

    testGoldens('renders CANCEL status correctly', (tester) async {
      final workPlan = WorkPlanFixtures.cancelledWorkPlan();

      await tester.pumpWidgetBuilder(
        createGoldenWidget(body: StatusBadge(workPlan: workPlan)),
      );
      await screenMatchesGolden(tester, 'status_badge_cancel');
    });
  });
}
