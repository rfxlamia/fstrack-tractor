import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/constants/ui_strings.dart';

void main() {
  group('UIStrings', () {
    test('should contain session related strings', () {
      expect(UIStrings.sessionExpiring,
          'Sesi akan berakhir. Login ulang saat online.');
      expect(UIStrings.sessionExpired,
          'Sesi telah berakhir. Silakan login kembali.');
      expect(UIStrings.sessionExpiringBannerText,
          'Sesi berakhir dalam {days} hari. Login ulang saat online.');
    });
  });
}
