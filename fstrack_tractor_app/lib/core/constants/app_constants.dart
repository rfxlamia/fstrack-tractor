/// Application-wide constants
///
/// Contains configuration values and constants used throughout the app.
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  /// WIB (Western Indonesian Time) timezone offset from UTC
  ///
  /// Indonesia uses 3 timezones:
  /// - WIB (Waktu Indonesia Barat / Western): UTC+7 (Jakarta, Sumatra)
  /// - WITA (Waktu Indonesia Tengah / Central): UTC+8 (Bali, Kalimantan)
  /// - WIT (Waktu Indonesia Timur / Eastern): UTC+9 (Papua, Maluku)
  ///
  /// **Business Decision:** All users operate in Jakarta timezone (WIB)
  /// regardless of device settings, as per Product Owner requirement.
  /// This ensures consistent greeting times and clock display for all users.
  ///
  /// **Migration Note:** If future requirement needs multi-timezone support,
  /// update this to use user preference or device timezone instead.
  static const Duration wibOffset = Duration(hours: 7);
}
