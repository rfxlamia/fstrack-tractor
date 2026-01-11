import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';

import 'connectivity_checker.dart';

/// ConnectivityService implementation using connectivity_plus
/// Implements debounce logic: 2-second delay for offline, immediate for online
@Singleton(as: ConnectivityChecker)
class ConnectivityService implements ConnectivityChecker {
  final Connectivity _connectivity;
  final _controller = StreamController<ConnectivityStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _debounceTimer;

  /// Constructor with injected Connectivity for testability
  ConnectivityService(this._connectivity) {
    _init();
  }

  void _init() {
    // connectivity_plus v6+ returns List<ConnectivityResult>
    _subscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      final isOffline = results.contains(ConnectivityResult.none);

      if (isOffline) {
        // Debounce offline detection - wait 2 seconds
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(seconds: 2), () {
          // Re-check after delay to ensure still offline
          _connectivity.checkConnectivity().then((recheck) {
            if (recheck.contains(ConnectivityResult.none)) {
              _controller.add(ConnectivityStatus.offline);
            }
          });
        });
      } else {
        // Online - emit immediately, cancel pending offline
        _debounceTimer?.cancel();
        _controller.add(ConnectivityStatus.online);
      }
    });
  }

  @override
  Stream<ConnectivityStatus> get onConnectivityChanged => _controller.stream;

  @override
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return !results.contains(ConnectivityResult.none);
  }

  @override
  @disposeMethod
  void dispose() {
    _debounceTimer?.cancel();
    _subscription?.cancel();
    _controller.close();
  }
}
