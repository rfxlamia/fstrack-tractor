import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/theme/app_theme.dart';
import 'package:fstrack_tractor/core/widgets/offline_banner.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  Widget createGoldenWidget() {
    return MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: OfflineBanner(
          onTap: null,
          isVisible: true,
        ),
      ),
    );
  }

  group('OfflineBanner Golden Tests', () {
    testGoldens('OfflineBanner visible state', (tester) async {
      await tester.pumpWidgetBuilder(
        createGoldenWidget(),
      );

      await screenMatchesGolden(tester, 'offline_banner_visible');
    });
  });
}
