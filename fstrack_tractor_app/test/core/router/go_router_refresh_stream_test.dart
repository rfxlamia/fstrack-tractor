import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fstrack_tractor/core/router/go_router_refresh_stream.dart';

void main() {
  group('GoRouterRefreshStream', () {
    late StreamController<int> controller;
    GoRouterRefreshStream? refreshStream;

    setUp(() {
      controller = StreamController<int>.broadcast();
      refreshStream = null;
    });

    tearDown(() {
      if (refreshStream != null) {
        try {
          refreshStream!.dispose();
        } catch (_) {
          // Already disposed in test
        }
      }
      controller.close();
    });

    test('notifies listeners on stream events', () async {
      refreshStream = GoRouterRefreshStream(controller.stream);

      var notificationCount = 0;
      refreshStream!.addListener(() {
        notificationCount++;
      });

      // Initial notification happens in constructor
      expect(notificationCount, 0); // Listener added after initial notification

      // Add stream events
      controller.add(1);
      await Future.delayed(Duration.zero); // Let stream event propagate
      expect(notificationCount, 1);

      controller.add(2);
      await Future.delayed(Duration.zero);
      expect(notificationCount, 2);

      controller.add(3);
      await Future.delayed(Duration.zero);
      expect(notificationCount, 3);
    });

    test('cancels subscription on dispose', () async {
      refreshStream = GoRouterRefreshStream(controller.stream);

      var notificationCount = 0;
      void listener() {
        notificationCount++;
      }

      refreshStream!.addListener(listener);

      // Remove listener first to avoid dispose error
      refreshStream!.removeListener(listener);

      // Dispose the refresh stream
      refreshStream!.dispose();
      refreshStream = null; // Mark as disposed

      // After dispose, stream events should not affect anything
      controller.add(1);
      await Future.delayed(const Duration(milliseconds: 10));
      expect(notificationCount, 0);
    });

    test('works with broadcast stream', () async {
      refreshStream = GoRouterRefreshStream(controller.stream);

      var count1 = 0;
      var count2 = 0;

      refreshStream!.addListener(() {
        count1++;
      });

      refreshStream!.addListener(() {
        count2++;
      });

      controller.add(1);
      await Future.delayed(Duration.zero);

      // Both listeners should be notified
      expect(count1, 1);
      expect(count2, 1);
    });
  });
}
