import 'package:flutter/material.dart';

/// Shared motion values so every transition in the app feels the same.
/// All animations that use these are finite, so tests can pumpAndSettle.
class AppMotion {
  AppMotion._();

  /// Icon swaps, chip highlights, small control changes.
  static const Duration fast = Duration(milliseconds: 150);

  /// Tab switches, sheet and section transitions.
  static const Duration normal = Duration(milliseconds: 220);

  /// The one easing curve the app uses, decelerating into place.
  static const Curve ease = Curves.easeOutCubic;
}

class AppTheme {
  static const List<Color> containerColors = [
    Color(0xFF6366F1), // indigo
    Color(0xFFEC4899), // pink
    Color(0xFFEF4444), // red
    Color(0xFFF59E0B), // amber
    Color(0xFF10B981), // emerald
    Color(0xFF3B82F6), // blue
    Color(0xFF8B5CF6), // violet
    Color(0xFF06B6D4), // cyan
    Color(0xFF84CC16), // lime
    Color(0xFFF97316), // orange
    Color(0xFFE11D48), // rose
    Color(0xFF6B7280), // gray
  ];

  static Color get accentColor => const Color(0xFF6366F1);

  static ThemeData lightTheme({Color? seed}) => _base(Brightness.light, seed);

  static ThemeData darkTheme({Color? seed}) => _base(Brightness.dark, seed);

  static ThemeData _base(Brightness brightness, Color? seed) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed ?? accentColor,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      // The bundled Inter family gives every screen its own voice instead
      // of the platform default.
      fontFamily: 'Inter',
      colorScheme: scheme,
      // One page transition everywhere: a short zoom that reads smooth on
      // every Android version and finishes fast enough for tests.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
        },
      ),
      // Flat cards with a soft tint: cheaper to draw than elevation shadows
      // and they read cleaner on long lists.
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
    );
  }
}
