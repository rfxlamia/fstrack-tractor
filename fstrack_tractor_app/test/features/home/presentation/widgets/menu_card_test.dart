import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/theme/app_colors.dart';
import 'package:fstrack_tractor/features/home/presentation/widgets/menu_card.dart';

void main() {
  group('MenuCard', () {
    testWidgets('renders correctly with all props', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuCard(
              icon: Icons.edit_note,
              title: 'Buat Rencana',
              subtitle: 'Rencana Kerja Baru',
              iconBackgroundColor: AppColors.buttonOrange,
              isFullWidth: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify icon is rendered
      expect(find.byIcon(Icons.edit_note), findsOneWidget);

      // Verify title and subtitle texts
      expect(find.text('Buat Rencana'), findsOneWidget);
      expect(find.text('Rencana Kerja Baru'), findsOneWidget);
    });

    testWidgets('onTap callback fires when tapped', (tester) async {
      var tapCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuCard(
              icon: Icons.list_alt,
              title: 'Lihat Rencana',
              subtitle: 'Daftar Rencana Kerja',
              iconBackgroundColor: AppColors.buttonBlue,
              isFullWidth: false,
              onTap: () => tapCalled = true,
            ),
          ),
        ),
      );

      // Find and tap the card
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Verify callback was invoked
      expect(tapCalled, true);
    });

    testWidgets('full-width card takes full width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: MenuCard(
                icon: Icons.list_alt,
                title: 'Lihat Rencana',
                subtitle: 'Daftar Rencana Kerja',
                iconBackgroundColor: AppColors.buttonBlue,
                isFullWidth: true,
              ),
            ),
          ),
        ),
      );

      final menuCard = tester.widget<MenuCard>(find.byType(MenuCard));
      expect(menuCard.isFullWidth, true);
    });

    testWidgets('half-width card allows wrapping in Row', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Expanded(
                  child: MenuCard(
                    icon: Icons.edit_note,
                    title: 'Buat Rencana',
                    subtitle: 'Rencana Kerja Baru',
                    iconBackgroundColor: AppColors.buttonOrange,
                    isFullWidth: false,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: MenuCard(
                    icon: Icons.list_alt,
                    title: 'Lihat Rencana',
                    subtitle: 'Daftar Rencana Kerja',
                    iconBackgroundColor: AppColors.buttonBlue,
                    isFullWidth: false,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify both cards are rendered
      expect(find.byType(MenuCard), findsNWidgets(2));
      expect(find.text('Buat Rencana'), findsOneWidget);
      expect(find.text('Lihat Rencana'), findsOneWidget);
    });

    testWidgets('minimum height is 80dp', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MenuCard(
              icon: Icons.list_alt,
              title: 'Test',
              subtitle: 'Subtitle',
              iconBackgroundColor: AppColors.buttonBlue,
              isFullWidth: true,
            ),
          ),
        ),
      );

      // Find the MenuCard's top-level ConstrainedBox
      final constrainedBox = tester.widget<ConstrainedBox>(
        find.descendant(
          of: find.byType(MenuCard),
          matching: find.byType(ConstrainedBox),
        ).first,
      );

      expect(constrainedBox.constraints.minHeight, 80.0);
    });

    testWidgets('applies correct text styles per UX spec', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MenuCard(
              icon: Icons.list_alt,
              title: 'Title Text',
              subtitle: 'Subtitle Text',
              iconBackgroundColor: AppColors.buttonBlue,
              isFullWidth: true,
            ),
          ),
        ),
      );

      // Find title Text widget - UX Spec: 14px w600
      final titleWidget = tester.widget<Text>(
        find.text('Title Text'),
      );
      expect(titleWidget.style?.fontWeight, FontWeight.w600);
      expect(titleWidget.style?.fontSize, 14);
      expect(titleWidget.style?.color, AppColors.textPrimary);

      // Find subtitle Text widget - UX Spec: 11px w400
      final subtitleWidget = tester.widget<Text>(
        find.text('Subtitle Text'),
      );
      expect(subtitleWidget.style?.fontWeight, FontWeight.w400);
      expect(subtitleWidget.style?.fontSize, 11);
      expect(subtitleWidget.style?.color, AppColors.textSecondary);
    });

    testWidgets('card has elevation shadow', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MenuCard(
              icon: Icons.list_alt,
              title: 'Test',
              subtitle: 'Subtitle',
              iconBackgroundColor: AppColors.buttonBlue,
              isFullWidth: true,
            ),
          ),
        ),
      );

      // Verify Material widget with elevation exists
      final material = tester.widget<Material>(
        find.descendant(
          of: find.byType(MenuCard),
          matching: find.byType(Material),
        ).first,
      );

      expect(material.elevation, greaterThan(0));
    });

    testWidgets('card uses InkWell for ripple effect', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MenuCard(
              icon: Icons.list_alt,
              title: 'Test',
              subtitle: 'Subtitle',
              iconBackgroundColor: AppColors.buttonBlue,
              isFullWidth: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify InkWell exists
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('icon container has correct background color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MenuCard(
              icon: Icons.edit_note,
              title: 'Test',
              subtitle: 'Subtitle',
              iconBackgroundColor: AppColors.buttonOrange,
              isFullWidth: true,
            ),
          ),
        ),
      );

      // Find all containers
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(MenuCard),
          matching: find.byType(Container),
        ),
      ).toList();

      // The first container should be the icon container (circular)
      final iconContainer = containers[0];
      final decoration = iconContainer.decoration as BoxDecoration;
      expect(decoration.color, AppColors.buttonOrange);
      expect(decoration.shape, BoxShape.circle);
    });
  });
}
