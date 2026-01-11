import 'dart:async';

import 'package:fstrack_tractor/core/network/connectivity_checker.dart';

/// Mock implementation of ConnectivityChecker for testing
/// Allows manual control of connectivity state
class MockConnectivityChecker implements ConnectivityChecker {
  final _controller = StreamController<ConnectivityStatus>.broadcast();
  bool _isOnline = true;

  /// Manually set online/offline status
  /// This will emit the status change to stream listeners
  void setOnline(bool value) {
    _isOnline = value;
    _controller.add(value ? ConnectivityStatus.online : ConnectivityStatus.offline);
  }

  @override
  Stream<ConnectivityStatus> get onConnectivityChanged => _controller.stream;

  @override
  Future<bool> isOnline() async => _isOnline;

  @override
  void dispose() => _controller.close();
}
