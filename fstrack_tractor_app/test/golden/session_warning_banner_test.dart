import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/features/auth/presentation/widgets/session_warning_banner.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  testGoldens('SessionWarningBanner golden test', (tester) async {
    final builder = GoldenBuilder.column()
      ..addScenario(
        '2 Days Remaining',
        const SessionWarningBanner(daysRemaining: 2),
      )
      ..addScenario(
        '1 Day Remaining',
        const SessionWarningBanner(daysRemaining: 1),
      )
      ..addScenario(
        '0 Days Remaining',
        const SessionWarningBanner(daysRemaining: 0),
      );

    await tester.pumpWidgetBuilder(builder.build());
    await screenMatchesGolden(tester, 'session_warning_banner');
  });
}
