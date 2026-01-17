import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:fstrack_tractor/features/home/data/datasources/first_time_local_data_source.dart';

void main() {
  late FirstTimeLocalDataSource dataSource;
  late Box testBox;
  late Directory tempDir;

  setUpAll(() async {
    // Use a temporary directory to avoid writing test artifacts into the repo.
    tempDir = await Directory.systemTemp.createTemp('fstrack_tractor_hive_test_');
    Hive.init(tempDir.path);
  });

  setUp(() async {
    // Open a fresh box for each test
    testBox = await Hive.openBox(FirstTimeLocalDataSource.boxName);
    await testBox.clear();
    dataSource = FirstTimeLocalDataSource();
  });

  tearDown(() async {
    await testBox.clear();
    await testBox.close();
  });

  tearDownAll(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  group('FirstTimeLocalDataSource', () {
    group('boxName', () {
      test('returns correct box name', () {
        expect(FirstTimeLocalDataSource.boxName, 'first_time_hints');
      });
    });

    group('getCompletedTooltips', () {
      test('returns empty set when nothing stored', () {
        final result = dataSource.getCompletedTooltips();
        expect(result, isEmpty);
      });

      test('returns stored tooltips as set', () async {
        await testBox.put('completed_tooltips', ['weather', 'menu_card']);

        final result = dataSource.getCompletedTooltips();

        expect(result, {'weather', 'menu_card'});
      });

      test('handles single tooltip', () async {
        await testBox.put('completed_tooltips', ['weather']);

        final result = dataSource.getCompletedTooltips();

        expect(result, {'weather'});
      });
    });

    group('markTooltipCompleted', () {
      test('adds tooltip to empty set', () async {
        await dataSource.markTooltipCompleted('weather');

        final result = dataSource.getCompletedTooltips();
        expect(result, contains('weather'));
      });

      test('adds tooltip to existing set', () async {
        await testBox.put('completed_tooltips', ['weather']);

        await dataSource.markTooltipCompleted('menu_card');

        final result = dataSource.getCompletedTooltips();
        expect(result, {'weather', 'menu_card'});
      });

      test('does not duplicate existing tooltip', () async {
        await testBox.put('completed_tooltips', ['weather']);

        await dataSource.markTooltipCompleted('weather');

        final result = dataSource.getCompletedTooltips();
        expect(result.length, 1);
        expect(result, {'weather'});
      });

      test('persists immediately', () async {
        await dataSource.markTooltipCompleted('weather');

        // Create new instance to verify persistence
        final newDataSource = FirstTimeLocalDataSource();
        final result = newDataSource.getCompletedTooltips();

        expect(result, contains('weather'));
      });
    });

    group('areAllTooltipsCompleted', () {
      test('returns false when no tooltips completed', () {
        expect(dataSource.areAllTooltipsCompleted(), isFalse);
      });

      test('returns false when only weather completed', () async {
        await testBox.put('completed_tooltips', ['weather']);

        expect(dataSource.areAllTooltipsCompleted(), isFalse);
      });

      test('returns false when only menu_card completed', () async {
        await testBox.put('completed_tooltips', ['menu_card']);

        expect(dataSource.areAllTooltipsCompleted(), isFalse);
      });

      test('returns true when both tooltips completed', () async {
        await testBox.put('completed_tooltips', ['weather', 'menu_card']);

        expect(dataSource.areAllTooltipsCompleted(), isTrue);
      });
    });

    group('getNextIncompleteTooltip', () {
      test('returns weather when nothing completed', () {
        expect(dataSource.getNextIncompleteTooltip(), 'weather');
      });

      test('returns menu_card when weather completed', () async {
        await testBox.put('completed_tooltips', ['weather']);

        expect(dataSource.getNextIncompleteTooltip(), 'menu_card');
      });

      test('returns null when all completed', () async {
        await testBox.put('completed_tooltips', ['weather', 'menu_card']);

        expect(dataSource.getNextIncompleteTooltip(), isNull);
      });
    });

    group('isTooltipCompleted', () {
      test('returns false for non-existent tooltip', () {
        expect(dataSource.isTooltipCompleted('weather'), isFalse);
      });

      test('returns true for completed tooltip', () async {
        await testBox.put('completed_tooltips', ['weather']);

        expect(dataSource.isTooltipCompleted('weather'), isTrue);
      });

      test('returns false for incomplete tooltip', () async {
        await testBox.put('completed_tooltips', ['weather']);

        expect(dataSource.isTooltipCompleted('menu_card'), isFalse);
      });
    });

    group('reset', () {
      test('clears all completed tooltips', () async {
        await testBox.put('completed_tooltips', ['weather', 'menu_card']);

        await dataSource.reset();

        expect(dataSource.getCompletedTooltips(), isEmpty);
      });

      test('works on empty state', () async {
        await dataSource.reset();

        expect(dataSource.getCompletedTooltips(), isEmpty);
      });
    });

    group('app kill recovery scenario', () {
      test('resumes from weather if app killed before any tooltip', () async {
        // Simulate fresh app start
        expect(dataSource.getNextIncompleteTooltip(), 'weather');
      });

      test('resumes from menu_card if app killed after weather', () async {
        // Simulate: user completed weather tooltip, then app was killed
        await dataSource.markTooltipCompleted('weather');

        // Simulate: app restart
        final newDataSource = FirstTimeLocalDataSource();

        expect(newDataSource.getNextIncompleteTooltip(), 'menu_card');
        expect(newDataSource.isTooltipCompleted('weather'), isTrue);
      });

      test('shows no tooltips if all were completed before kill', () async {
        // Simulate: user completed all tooltips
        await dataSource.markTooltipCompleted('weather');
        await dataSource.markTooltipCompleted('menu_card');

        // Simulate: app restart
        final newDataSource = FirstTimeLocalDataSource();

        expect(newDataSource.areAllTooltipsCompleted(), isTrue);
        expect(newDataSource.getNextIncompleteTooltip(), isNull);
      });
    });
  });
}
