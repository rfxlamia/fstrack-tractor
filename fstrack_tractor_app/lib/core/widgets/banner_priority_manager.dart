enum BannerType { sessionWarning, offline }

class BannerPriorityManager {
  const BannerPriorityManager();

  /// Returns the highest priority banner that should be shown.
  /// Priority: sessionWarning > offline.
  BannerType? getActiveBanner({
    required bool isOffline,
    required bool shouldShowSessionWarning,
  }) {
    if (shouldShowSessionWarning) return BannerType.sessionWarning;
    if (isOffline) return BannerType.offline;
    return null;
  }
}
