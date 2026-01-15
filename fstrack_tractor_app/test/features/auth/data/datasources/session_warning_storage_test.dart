import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/storage/hive_service.dart';
import 'package:fstrack_tractor/features/auth/data/datasources/session_warning_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';

class MockHiveService extends Mock implements HiveService {}
class MockBox extends Mock implements Box {}

void main() {
  late MockHiveService mockHiveService;
  late MockBox mockAuthBox;
  late SessionWarningStorageImpl storage;

  setUp(() {
    mockHiveService = MockHiveService();
    mockAuthBox = MockBox();
    when(() => mockHiveService.authBox).thenReturn(mockAuthBox);
    storage = SessionWarningStorageImpl(mockHiveService);
  });

  group('SessionWarningStorage', () {
    test('getLastWarningShownAt returns null when no timestamp exists', () async {
      when(() => mockAuthBox.get('lastWarningShownAt')).thenReturn(null);

      final result = await storage.getLastWarningShownAt();

      expect(result, isNull);
    });

    test('getLastWarningShownAt returns DateTime when timestamp exists', () async {
      final now = DateTime.now();
      when(() => mockAuthBox.get('lastWarningShownAt')).thenReturn(now.toIso8601String());

      final result = await storage.getLastWarningShownAt();

      expect(result, isNotNull);
      expect(result!.year, now.year);
    });

    test('setLastWarningShownAt saves timestamp to box', () async {
      final now = DateTime.now();
      when(() => mockAuthBox.put('lastWarningShownAt', any())).thenAnswer((_) async {});

      await storage.setLastWarningShownAt(now);

      verify(() => mockAuthBox.put('lastWarningShownAt', now.toIso8601String())).called(1);
    });

    test('clearWarningTimestamp deletes key from box', () async {
      when(() => mockAuthBox.delete('lastWarningShownAt')).thenAnswer((_) async {});

      await storage.clearWarningTimestamp();

      verify(() => mockAuthBox.delete('lastWarningShownAt')).called(1);
    });
  });
}
