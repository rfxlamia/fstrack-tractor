import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/theme/app_colors.dart';
import 'package:fstrack_tractor/core/utils/date_formatter.dart';
import 'package:fstrack_tractor/features/work_plan/presentation/widgets/status_badge.dart';
import 'package:fstrack_tractor/features/work_plan/presentation/widgets/work_plan_card.dart';

import '../../../../fixtures/work_plan_fixtures.dart';

void main() {
  group('WorkPlanCard', () {
    testWidgets('displays formatted date correctly', (tester) async {
      final workPlan = WorkPlanFixtures.openWorkPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkPlanCard(workPlan: workPlan),
          ),
        ),
      );

      expect(find.text(formatWorkDate(workPlan.workDate)), findsOneWidget);
    });

    testWidgets('displays pattern and shift', (tester) async {
      final workPlan = WorkPlanFixtures.openWorkPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkPlanCard(workPlan: workPlan),
          ),
        ),
      );

      expect(find.text('${workPlan.pattern} - ${workPlan.shift}'), findsOneWidget);
    });

    testWidgets('displays location ID', (tester) async {
      final workPlan = WorkPlanFixtures.openWorkPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkPlanCard(workPlan: workPlan),
          ),
        ),
      );

      expect(find.text(workPlan.locationId), findsOneWidget);
    });

    testWidgets('displays status badge', (tester) async {
      final workPlan = WorkPlanFixtures.openWorkPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkPlanCard(workPlan: workPlan),
          ),
        ),
      );

      expect(find.byType(StatusBadge), findsOneWidget);
    });

    testWidgets('has orange left border for OPEN status', (tester) async {
      final workPlan = WorkPlanFixtures.openWorkPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkPlanCard(workPlan: workPlan),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;

      expect(border.left.color, AppColors.buttonOrange);
      expect(border.left.width, 4);
    });

    testWidgets('has blue left border for CLOSED status', (tester) async {
      final workPlan = WorkPlanFixtures.closedWorkPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkPlanCard(workPlan: workPlan),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;

      expect(border.left.color, AppColors.buttonBlue);
    });

    testWidgets('has red left border for CANCEL status', (tester) async {
      final workPlan = WorkPlanFixtures.cancelledWorkPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkPlanCard(workPlan: workPlan),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;

      expect(border.left.color, AppColors.error);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      final workPlan = WorkPlanFixtures.openWorkPlan();
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkPlanCard(
              workPlan: workPlan,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(WorkPlanCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('has correct border radius', (tester) async {
      final workPlan = WorkPlanFixtures.openWorkPlan();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WorkPlanCard(workPlan: workPlan),
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.borderRadius, BorderRadius.circular(8));
    });
  });
}
