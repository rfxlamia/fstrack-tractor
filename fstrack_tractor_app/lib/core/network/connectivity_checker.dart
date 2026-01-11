/// Abstract interface for connectivity checking
/// Allows mocking in tests and dependency injection
abstract class ConnectivityChecker {
  /// Stream of connectivity status changes
  /// Emits ConnectivityStatus.online or ConnectivityStatus.offline
  Stream<ConnectivityStatus> get onConnectivityChanged;

  /// Check if device is currently online
  /// Returns true if connected to network, false otherwise
  Future<bool> isOnline();

  /// Dispose resources (cancel subscriptions)
  void dispose();
}

/// Connectivity status enum
/// Used to represent device network connectivity state
enum ConnectivityStatus {
  /// Device is connected to network
  online,

  /// Device is not connected to network
  offline,
}
