import 'package:flutter/material.dart';

/// Shared motion values so every transition in the app feels the same.
/// All animations that use these are finite, so tests can pumpAndSettle.
class AppMotion {
  AppMotion._();

  /// Icon swaps, chip highlights, small control changes.
  static const Duration fast = Duration(milliseconds: 150);

  /// Tab switches, sheet and section transitions.
  static const Duration normal = Duration(milliseconds: 220);

  /// Extra time per step in a staggered entrance. Six steps add at most
  /// 180ms, so the longest entrance stays under 400ms and still settles
  /// inside the 350ms fixed pumps the navigation tests use.
  static const Duration stagger = Duration(milliseconds: 30);

  /// The one easing curve the app uses, decelerating into place.
  static const Curve ease = Curves.easeOutCubic;
}

/// The spacing scale every screen follows, in multiples of four, so
/// padding and margins read the same from the drawer to the last card.
class AppSpacing {
  AppSpacing._();

  /// Small gaps inside one component (icon to label, chip to chip).
  static const double xs = 4;

  /// Row and section gaps.
  static const double sm = 8;

  /// Standard margins: list rows, sheet padding, drawer insets.
  static const double md = 16;

  /// Large gaps: page top, dialog buttons, hero bands.
  static const double lg = 24;

  /// Biggest gaps: onboarding top spacer, first frame breathing room.
  static const double xl = 32;
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

  /// The brand gradient behind the logo bands: the same indigo to violet
  /// the launcher icon uses, so the drawer and setup headers carry the
  /// mark wherever the app opens.
  static LinearGradient get brandGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

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
      // A flat, low elevation bar: the tab title stays readable, and the
      // bar lifts by one point once the body scrolls under it.
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
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
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        highlightElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        bodyMedium: TextStyle(fontSize: 14),
        bodySmall: TextStyle(fontSize: 12),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
