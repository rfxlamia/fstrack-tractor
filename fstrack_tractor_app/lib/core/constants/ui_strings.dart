/// UI text strings used throughout the application
///
/// Contains hardcoded strings for UI elements. Centralizing strings here
/// makes future internationalization (i18n/l10n) easier.
///
/// **Future i18n Note:** When implementing multi-language support,
/// migrate these constants to Flutter's AppLocalizations system.
class UIStrings {
  UIStrings._(); // Private constructor to prevent instantiation

  // HomePage placeholder texts
  static const String menuCardsPlaceholderTitle = 'Menu Cards';
  static const String menuCardsPlaceholderSubtitle =
      'Akan ditambahkan di Story 3.4';

  // Weather widget strings
  static const String weatherLoading = 'Memuat cuaca...';
  static const String weatherUnavailable = 'Cuaca tidak tersedia';
  static const String weatherCachedPrefix = 'Data terakhir tersedia';
  static const String weatherRetry = 'Coba Lagi';
  static const String weatherDisclaimer = 'Prakiraan cuaca, dapat berubah';
  static const String weatherUpdatedPrefix = 'Diperbarui:';
}
