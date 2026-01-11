import 'package:injectable/injectable.dart';

import '../../../../core/network/connectivity_checker.dart';
import '../repositories/auth_repository.dart';

/// Use case for validating stored token with grace period
/// Implements offline grace period: 24 hours after expiry when offline
@injectable
class ValidateTokenUseCase {
  final AuthRepository _authRepository;
  final ConnectivityChecker _connectivityChecker;

  static const _gracePeriod = Duration(hours: 24);

  ValidateTokenUseCase(
    this._authRepository,
    this._connectivityChecker,
  );

  /// Validate if stored token is still valid
  /// Returns true if token is valid or within grace period when offline
  ///
  /// Logic:
  /// - Token not expired → return true
  /// - Token expired + online → return false
  /// - Token expired < 24h + offline → return true (grace period)
  /// - Token expired > 24h + offline → return false
  Future<bool> call() async {
    final expiresAt = await _authRepository.getTokenExpiry();
    if (expiresAt == null) return false;

    final now = DateTime.now();
    if (expiresAt.isAfter(now)) return true; // Not expired

    // Expired - check grace period (offline only)
    final isOffline = !(await _connectivityChecker.isOnline());
    return isOffline && expiresAt.add(_gracePeriod).isAfter(now);
  }
}
