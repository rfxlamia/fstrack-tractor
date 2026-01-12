import 'dart:async';

import 'package:flutter/foundation.dart';

/// Converts a Stream to a Listenable for GoRouter's refreshListenable.
///
/// This adapter allows go_router to listen to BLoC state changes and
/// re-evaluate routes when authentication state changes.
///
/// Usage:
/// ```dart
/// refreshListenable: GoRouterRefreshStream(authBloc.stream)
/// ```
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  /// Creates a [GoRouterRefreshStream] that listens to the given stream.
  ///
  /// Notifies listeners whenever the stream emits a new value, triggering
  /// go_router to re-evaluate the redirect logic.
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // Initial notification
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
