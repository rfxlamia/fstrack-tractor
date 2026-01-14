import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/constants/ui_strings.dart';
import 'package:fstrack_tractor/core/theme/app_colors.dart';
import 'package:fstrack_tractor/core/theme/app_spacing.dart';
import 'package:fstrack_tractor/core/widgets/offline_banner.dart';

void main() {
  testWidgets('OfflineBanner renders with correct styling', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OfflineBanner(
            onTap: null,
            isVisible: true,
          ),
        ),
      ),
    );

    expect(find.text(UIStrings.offlineBannerText), findsOneWidget);
    expect(find.byIcon(Icons.cloud_off), findsOneWidget);

    final material = tester.widget<Material>(
      find.descendant(
        of: find.byType(OfflineBanner),
        matching: find.byType(Material),
      ),
    );
    expect(material.color, AppColors.bannerWarning);

    final size = tester.getSize(find.byType(OfflineBanner));
    expect(size.height, AppSpacing.touchTargetMin);
  });

  testWidgets('OfflineBanner fires onTap callback', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OfflineBanner(
            onTap: () => tapped = true,
            isVisible: true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(OfflineBanner));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
