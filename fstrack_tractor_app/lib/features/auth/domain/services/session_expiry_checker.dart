abstract class SessionExpiryChecker {
  Future<int> getDaysUntilExpiry();
  Future<bool> shouldShowWarning();
  Future<bool> isSessionExpired();
  Future<bool> isGracePeriodPassed();
  Future<bool> canShowWarningToday();
  Future<void> markWarningShown();
}
