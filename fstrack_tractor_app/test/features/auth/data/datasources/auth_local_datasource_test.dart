import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/storage/hive_service.dart';
import 'package:fstrack_tractor/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockHiveService extends Mock implements HiveService {}

class MockBox extends Mock implements Box {}

void main() {
  late MockHiveService mockHiveService;
  late MockBox mockAuthBox;
  late AuthLocalDataSource dataSource;

  setUp(() {
    mockHiveService = MockHiveService();
    mockAuthBox = MockBox();
    when(() => mockHiveService.authBox).thenReturn(mockAuthBox);
    dataSource = AuthLocalDataSource(hiveService: mockHiveService);
  });

  group('AuthLocalDataSource Expiry Methods', () {
    test('getDaysUntilExpiry returns -1 if no expiry date', () async {
      when(() => mockAuthBox.get('expiresAt')).thenReturn(null);
      expect(await dataSource.getDaysUntilExpiry(), -1);
    });

    test('getDaysUntilExpiry returns correct days', () async {
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(days: 2, hours: 1));
      when(() => mockAuthBox.get('expiresAt'))
          .thenReturn(expiresAt.toIso8601String());
      expect(await dataSource.getDaysUntilExpiry(), 2);
    });

    test('shouldShowExpiryWarning returns true if days <= 2', () async {
      final now = DateTime.now();
      final expiresAt = now.add(const Duration(days: 2));
      when(() => mockAuthBox.get('expiresAt'))
          .thenReturn(expiresAt.toIso8601String());
      expect(await dataSource.shouldShowExpiryWarning(), true);
    });

    test('isGracePeriodPassed returns true if > 24h past expiry', () async {
      final now = DateTime.now();
      // expired 25 hours ago
      final expiresAt = now.subtract(const Duration(hours: 25));
      when(() => mockAuthBox.get('expiresAt'))
          .thenReturn(expiresAt.toIso8601String());

      expect(await dataSource.isGracePeriodPassed(), true);
    });

    test('isGracePeriodPassed returns false if < 24h past expiry', () async {
      final now = DateTime.now();
      // expired 23 hours ago
      final expiresAt = now.subtract(const Duration(hours: 23));
      when(() => mockAuthBox.get('expiresAt'))
          .thenReturn(expiresAt.toIso8601String());

      expect(await dataSource.isGracePeriodPassed(), false);
    });
  });
}
