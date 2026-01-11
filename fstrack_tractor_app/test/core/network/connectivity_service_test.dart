import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/network/connectivity_checker.dart';
import 'package:fstrack_tractor/core/network/connectivity_service.dart';
import 'package:mocktail/mocktail.dart';

class MockConnectivity extends Mock implements Connectivity {}

void main() {
  group('ConnectivityService', () {
    late ConnectivityService connectivityService;
    late MockConnectivity mockConnectivity;
    late StreamController<List<ConnectivityResult>> connectivityController;

    setUp(() {
      mockConnectivity = MockConnectivity();
      connectivityController =
          StreamController<List<ConnectivityResult>>.broadcast();

      when(() => mockConnectivity.onConnectivityChanged)
          .thenAnswer((_) => connectivityController.stream);
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      connectivityService = ConnectivityService(mockConnectivity);
    });

    tearDown(() {
      connectivityService.dispose();
      connectivityController.close();
    });

    test('exposes connectivity status stream', () {
      expect(
        connectivityService.onConnectivityChanged,
        isA<Stream<ConnectivityStatus>>(),
      );
    });

    test('dispose cancels subscriptions without error', () {
      expect(() => connectivityService.dispose(), returnsNormally);
    });

    test('emits online immediately when connectivity is restored', () async {
      // Arrange
      final statusList = <ConnectivityStatus>[];
      final subscription =
          connectivityService.onConnectivityChanged.listen(statusList.add);

      // Act - simulate online event
      connectivityController.add([ConnectivityResult.wifi]);

      // Give stream time to process
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Assert - online should be emitted immediately
      expect(statusList, contains(ConnectivityStatus.online));

      await subscription.cancel();
    });

    test('debounces offline detection by 2 seconds', () async {
      // Arrange
      final statusList = <ConnectivityStatus>[];
      final subscription =
          connectivityService.onConnectivityChanged.listen(statusList.add);

      // Mock checkConnectivity to return offline
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      // Act - simulate offline event
      connectivityController.add([ConnectivityResult.none]);

      // Wait less than debounce time
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Assert - offline should NOT be emitted yet
      expect(statusList.contains(ConnectivityStatus.offline), isFalse);

      // Wait for debounce to complete (2 seconds total)
      await Future<void>.delayed(const Duration(seconds: 2));

      // Assert - offline should now be emitted
      expect(statusList, contains(ConnectivityStatus.offline));

      await subscription.cancel();
    });

    test('cancels offline debounce when online is restored', () async {
      // Arrange
      final statusList = <ConnectivityStatus>[];
      final subscription =
          connectivityService.onConnectivityChanged.listen(statusList.add);

      // Mock checkConnectivity to return offline initially
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      // Act - simulate offline event
      connectivityController.add([ConnectivityResult.none]);

      // Wait partial debounce time
      await Future<void>.delayed(const Duration(milliseconds: 500));

      // Simulate online restored before debounce completes
      connectivityController.add([ConnectivityResult.wifi]);

      // Wait for original debounce to have completed if it wasn't cancelled
      await Future<void>.delayed(const Duration(seconds: 2));

      // Assert - should have online but NOT offline
      expect(statusList, contains(ConnectivityStatus.online));
      expect(statusList.contains(ConnectivityStatus.offline), isFalse);

      await subscription.cancel();
    });

    test('isOnline returns true when wifi connected', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      // Act
      final result = await connectivityService.isOnline();

      // Assert
      expect(result, isTrue);
    });

    test('isOnline returns true when mobile connected', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);

      // Act
      final result = await connectivityService.isOnline();

      // Assert
      expect(result, isTrue);
    });

    test('isOnline returns false when no connectivity', () async {
      // Arrange
      when(() => mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      // Act
      final result = await connectivityService.isOnline();

      // Assert
      expect(result, isFalse);
    });
  });
}
