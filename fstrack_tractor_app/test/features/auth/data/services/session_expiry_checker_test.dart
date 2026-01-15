import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:fstrack_tractor/features/auth/data/datasources/session_warning_storage.dart';
import 'package:fstrack_tractor/features/auth/data/services/session_expiry_checker_impl.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockSessionWarningStorage extends Mock implements SessionWarningStorage {}

void main() {
  late MockAuthLocalDataSource mockAuth;
  late MockSessionWarningStorage mockStorage;
  late SessionExpiryCheckerImpl checker;

  setUp(() {
    mockAuth = MockAuthLocalDataSource();
    mockStorage = MockSessionWarningStorage();
    checker = SessionExpiryCheckerImpl(mockAuth, mockStorage);
  });

  group('SessionExpiryChecker', () {
    test('getDaysUntilExpiry returns -1 if no expiry date', () async {
      when(() => mockAuth.getDaysUntilExpiry()).thenAnswer((_) async => -1);
      expect(await checker.getDaysUntilExpiry(), -1);
    });

    test('getDaysUntilExpiry returns correct days', () async {
      when(() => mockAuth.getDaysUntilExpiry()).thenAnswer((_) async => 2);

      expect(await checker.getDaysUntilExpiry(), 2);
    });

    test('shouldShowWarning returns true if days <= 2 and >= 0', () async {
      when(() => mockAuth.shouldShowExpiryWarning())
          .thenAnswer((_) async => true);
      expect(await checker.shouldShowWarning(), true);
    });

    test('shouldShowWarning returns false if days > 2', () async {
      when(() => mockAuth.shouldShowExpiryWarning())
          .thenAnswer((_) async => false);
      expect(await checker.shouldShowWarning(), false);
    });

    test('canShowWarningToday returns true if last warning was > 24h ago',
        () async {
      final lastShown = DateTime.now().subtract(const Duration(hours: 25));
      when(() => mockStorage.getLastWarningShownAt())
          .thenAnswer((_) async => lastShown);

      expect(await checker.canShowWarningToday(), true);
    });

    test('canShowWarningToday returns false if last warning was < 24h ago',
        () async {
      final lastShown = DateTime.now().subtract(const Duration(hours: 23));
      when(() => mockStorage.getLastWarningShownAt())
          .thenAnswer((_) async => lastShown);

      expect(await checker.canShowWarningToday(), false);
    });
  });
}
