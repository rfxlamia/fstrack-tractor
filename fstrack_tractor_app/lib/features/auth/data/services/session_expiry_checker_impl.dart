import 'package:injectable/injectable.dart';
import '../../domain/services/session_expiry_checker.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/session_warning_storage.dart';

@LazySingleton(as: SessionExpiryChecker)
class SessionExpiryCheckerImpl implements SessionExpiryChecker {
  final AuthLocalDataSource _authLocalDataSource;
  final SessionWarningStorage _sessionWarningStorage;

  SessionExpiryCheckerImpl(
    this._authLocalDataSource,
    this._sessionWarningStorage,
  );

  @override
  Future<int> getDaysUntilExpiry() async {
    return _authLocalDataSource.getDaysUntilExpiry();
  }

  @override
  Future<bool> shouldShowWarning() async {
    return _authLocalDataSource.shouldShowExpiryWarning();
  }

  @override
  Future<bool> isSessionExpired() async {
    final expiresAt = await _authLocalDataSource.getExpiresAt();
    if (expiresAt == null) return true;
    return DateTime.now().isAfter(expiresAt);
  }

  @override
  Future<bool> isGracePeriodPassed() async {
    return _authLocalDataSource.isGracePeriodPassed();
  }

  @override
  Future<bool> canShowWarningToday() async {
    final lastShown = await _sessionWarningStorage.getLastWarningShownAt();
    if (lastShown == null) return true;

    final hoursSinceLastShown = DateTime.now().difference(lastShown).inHours;
    return hoursSinceLastShown >= 24;
  }

  @override
  Future<void> markWarningShown() async {
    await _sessionWarningStorage.setLastWarningShownAt(DateTime.now());
  }
}
