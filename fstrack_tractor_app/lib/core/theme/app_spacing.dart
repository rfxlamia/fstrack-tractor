/// Design tokens from UX Spec + Warm Friendly Final Direction
///
/// This class provides centralized spacing, radius, and UI constants
/// for consistent design throughout the app.
///
/// Spacing values from UX Spec (NOT 4/8 pattern):
/// - xs = 8, sm = 12, md = 16, lg = 24, xl = 32
///
/// Radius values from Warm Friendly - Final Direction:
/// - radiusSm = 12, radiusMd = 16, radiusLg = 20, radiusXl = 24
/// - inputRadius = 8 (for input fields only)
abstract class AppSpacing {
  // ==========================================
  // Spacing Constants (from UX Spec lines 541-547)
  // ==========================================
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  // ==========================================
  // Radius Constants (from Warm Friendly)
  // ==========================================
  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0; // Default for cards, buttons
  static const double radiusLg = 20.0;
  static const double radiusXl = 24.0; // For bottom sheets
  static const double inputRadius = 8.0; // Input fields only

  // ==========================================
  // UI Constants
  // ==========================================
  static const double buttonHeight = 60.0;
  static const double touchTargetMin = 48.0; // Accessibility minimum
}
