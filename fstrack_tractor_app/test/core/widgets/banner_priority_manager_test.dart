import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/widgets/banner_priority_manager.dart';

void main() {
  group('BannerPriorityManager', () {
    test('returns offline when only offline is true', () {
      const manager = BannerPriorityManager();

      final result = manager.getActiveBanner(
        isOffline: true,
        shouldShowSessionWarning: false,
      );

      expect(result, BannerType.offline);
    });

    test('returns session warning when only session warning is true', () {
      const manager = BannerPriorityManager();

      final result = manager.getActiveBanner(
        isOffline: false,
        shouldShowSessionWarning: true,
      );

      expect(result, BannerType.sessionWarning);
    });

    test('returns session warning when both are true', () {
      const manager = BannerPriorityManager();

      final result = manager.getActiveBanner(
        isOffline: true,
        shouldShowSessionWarning: true,
      );

      expect(result, BannerType.sessionWarning);
    });

    test('returns null when neither condition is true', () {
      const manager = BannerPriorityManager();

      final result = manager.getActiveBanner(
        isOffline: false,
        shouldShowSessionWarning: false,
      );

      expect(result, isNull);
    });
  });
}
