import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/shared/widgets/tooltip_overlay.dart';

void main() {
  group('TooltipOverlay', () {
    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TooltipOverlay(
              message: 'Test message',
              position: TooltipPosition.bottom,
              onDismiss: () {},
              child: const Text('Target Widget'),
            ),
          ),
        ),
      );

      expect(find.text('Target Widget'), findsOneWidget);
    });

    testWidgets('shows tooltip message in overlay', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TooltipOverlay(
              message: 'Lihat prakiraan cuaca',
              position: TooltipPosition.bottom,
              onDismiss: () {},
              child: const Text('Weather'),
            ),
          ),
        ),
      );

      // Wait for post frame callback and animation
      await tester.pumpAndSettle();

      expect(find.text('Lihat prakiraan cuaca'), findsOneWidget);
    });

    testWidgets('shows Mengerti dismiss button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TooltipOverlay(
              message: 'Test message',
              position: TooltipPosition.bottom,
              onDismiss: () {},
              child: const Text('Target'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Mengerti'), findsOneWidget);
    });

    testWidgets('calls onDismiss when button tapped', (tester) async {
      var dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TooltipOverlay(
              message: 'Test message',
              position: TooltipPosition.bottom,
              onDismiss: () => dismissed = true,
              child: const Text('Target'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Mengerti'));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    testWidgets('calls onDismiss when overlay background tapped',
        (tester) async {
      var dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TooltipOverlay(
              message: 'Test message',
              position: TooltipPosition.bottom,
              onDismiss: () => dismissed = true,
              child: const Text('Target'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on the overlay background (top-left corner)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    testWidgets('renders with TooltipPosition.top', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TooltipOverlay(
                message: 'Top positioned tooltip',
                position: TooltipPosition.top,
                onDismiss: () {},
                child: const Text('Target'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Top positioned tooltip'), findsOneWidget);
    });

    testWidgets('renders with TooltipPosition.bottom', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TooltipOverlay(
                message: 'Bottom positioned tooltip',
                position: TooltipPosition.bottom,
                onDismiss: () {},
                child: const Text('Target'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Bottom positioned tooltip'), findsOneWidget);
    });

    testWidgets('has proper accessibility semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TooltipOverlay(
              message: 'Accessibility test message',
              position: TooltipPosition.bottom,
              onDismiss: () {},
              child: const Text('Target'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify semantics is present with the message
      final semantics = tester.getSemantics(find.byType(Column).last);
      expect(semantics.label, contains('Accessibility test message'));
    });
  });

  group('TooltipPosition', () {
    test('has top and bottom values', () {
      expect(TooltipPosition.values.length, 2);
      expect(TooltipPosition.values, contains(TooltipPosition.top));
      expect(TooltipPosition.values, contains(TooltipPosition.bottom));
    });
  });

  group('TooltipOverlayTheme', () {
    test('has correct overlay color (50% opacity)', () {
      expect(TooltipOverlayTheme.overlayColor, Colors.black54);
    });

    test('has white tooltip background', () {
      expect(TooltipOverlayTheme.tooltipBackground, Colors.white);
    });

    test('has 8.0 border radius', () {
      expect(TooltipOverlayTheme.tooltipBorderRadius, 8.0);
    });

    test('has 12.0 arrow size', () {
      expect(TooltipOverlayTheme.arrowSize, 12.0);
    });

    test('has 300ms animation duration', () {
      expect(TooltipOverlayTheme.animationDuration,
          const Duration(milliseconds: 300));
    });

    test('has 280.0 max width', () {
      expect(TooltipOverlayTheme.tooltipMaxWidth, 280.0);
    });
  });
}
