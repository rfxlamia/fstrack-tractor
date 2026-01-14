import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/constants/ui_strings.dart';
import 'package:fstrack_tractor/features/home/presentation/widgets/coming_soon_bottom_sheet.dart';

void main() {
  group('ComingSoonBottomSheet', () {
    testWidgets('displays correct content', (tester) async {
      const testFeature = 'Buat Rencana Kerja';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () =>
                      ComingSoonBottomSheet.show(context, testFeature),
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show bottom sheet
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Verify construction icon
      expect(find.byIcon(Icons.construction), findsOneWidget);

      // Verify title
      expect(find.text(UIStrings.comingSoonTitle), findsOneWidget);

      // Verify subtitle with feature name
      expect(
        find.text('Fitur $testFeature ${UIStrings.comingSoonSubtitle}'),
        findsOneWidget,
      );

      // Verify close button
      expect(find.text(UIStrings.comingSoonClose), findsOneWidget);
    });

    testWidgets('close button dismisses sheet', (tester) async {
      const testFeature = 'Test Feature';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () =>
                      ComingSoonBottomSheet.show(context, testFeature),
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show bottom sheet
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Verify bottom sheet is visible
      expect(find.byType(ComingSoonBottomSheet), findsOneWidget);

      // Tap close button
      await tester.tap(find.text(UIStrings.comingSoonClose));
      await tester.pumpAndSettle();

      // Verify bottom sheet is dismissed
      expect(find.byType(ComingSoonBottomSheet), findsNothing);
    });

    testWidgets('is dismissible via swipe down', (tester) async {
      const testFeature = 'Test Feature';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () =>
                      ComingSoonBottomSheet.show(context, testFeature),
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show bottom sheet
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Verify bottom sheet is visible
      expect(find.byType(ComingSoonBottomSheet), findsOneWidget);

      // Swipe down to dismiss
      await tester.drag(
        find.byType(ComingSoonBottomSheet),
        const Offset(0, 500),
      );
      await tester.pumpAndSettle();

      // Verify bottom sheet is dismissed
      expect(find.byType(ComingSoonBottomSheet), findsNothing);
    });

    testWidgets('uses correct icon size and color', (tester) async {
      const testFeature = 'Test Feature';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () =>
                      ComingSoonBottomSheet.show(context, testFeature),
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      // Tap button to show bottom sheet
      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      // Find the construction icon
      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.construction));

      // Verify icon size is 64
      expect(iconWidget.size, 64);
    });
  });
}
