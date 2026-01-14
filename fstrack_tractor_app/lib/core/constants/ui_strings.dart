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

  // Offline Banner
  static const String offlineBannerText = 'Offline - Tap untuk refresh';
  static const String offlineRetryMessage = 'Mencoba menghubungkan ulang...';
  static const String offlineBannerSemanticsLabel = 'Offline. Tap untuk refresh';

  // Menu Cards
  static const String menuCardCreateTitle = 'Buat Rencana';
  static const String menuCardCreateSubtitle = 'Rencana Kerja Baru';
  static const String menuCardViewTitle = 'Lihat Rencana';
  static const String menuCardViewSubtitle = 'Daftar Rencana Kerja';

  // Coming Soon
  static const String comingSoonTitle = 'Fitur Segera Hadir';
  static const String comingSoonSubtitle = 'sedang dalam pengembangan';
  static const String comingSoonClose = 'Tutup';
}
