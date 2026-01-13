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
  static const String weatherPlaceholderTitle = 'Weather Widget';
  static const String weatherPlaceholderSubtitle =
      'Akan ditambahkan di Story 3.3';

  static const String menuCardsPlaceholderTitle = 'Menu Cards';
  static const String menuCardsPlaceholderSubtitle =
      'Akan ditambahkan di Story 3.4';
}
