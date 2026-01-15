import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/error/failures.dart';
import 'package:fstrack_tractor/core/constants/ui_strings.dart';

void main() {
  group('SessionExpiredFailure', () {
    test('should return correct message from UIStrings', () {
      final failure = SessionExpiredFailure();
      expect(failure.message, UIStrings.sessionExpired);
    });
  });
}
