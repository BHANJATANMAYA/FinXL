import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color surface = Color(0xFFF7F9FC);
  static const Color onSurface = Color(0xFF191C1E);
  static const Color onSurfaceVariant = Color(0xFF52606D);
  static const Color primary = Color(0xFF006D37);
  static const Color primaryContainer = Color(0xFF2ECC71);
  static const Color secondary = Color(0xFF0F6CBD);
  static const Color tertiary = Color(0xFFC67B17);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFB42318);
  static const Color surfaceContainerLowest = Colors.white;
  static const Color surfaceContainerLow = Color(0xFFF2F4F7);
  static const Color surfaceContainer = Color(0xFFECEFF3);
  static const Color surfaceContainerHigh = Color(0xFFDCE2E8);
  static const Color surfaceContainerHighest = Color(0xFFC9D3DD);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryContainer],
  );

  static ThemeData get lightTheme {
    final textTheme = TextTheme(
      displayLarge: GoogleFonts.manrope(
        color: onSurface,
        fontWeight: FontWeight.w800,
      ),
      displayMedium: GoogleFonts.manrope(
        color: onSurface,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: GoogleFonts.manrope(
        color: onSurface,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.manrope(
        color: onSurface,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: GoogleFonts.inter(color: onSurface),
      bodyMedium: GoogleFonts.inter(color: onSurface),
      labelLarge: GoogleFonts.inter(
        color: onSurfaceVariant,
        fontWeight: FontWeight.w600,
      ),
      labelMedium: GoogleFonts.inter(
        color: onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      colorScheme: const ColorScheme.light(
        surface: surface,
        onSurface: onSurface,
        primary: primary,
        primaryContainer: primaryContainer,
        secondary: secondary,
        tertiary: tertiary,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      textTheme: textTheme,
    );
  }

  static BoxDecoration cardDecoration({
    Color? color,
    Border? border,
    List<BoxShadow>? boxShadow,
  }) {
    return BoxDecoration(
      color: color ?? surfaceContainerLowest,
      borderRadius: BorderRadius.circular(32),
      border: border,
      boxShadow:
          boxShadow ??
          [
            BoxShadow(
              color: onSurface.withValues(alpha: 0.05),
              blurRadius: 40,
              offset: const Offset(0, 18),
            ),
          ],
    );
  }

  static Color accentColor(String accent) {
    return switch (accent) {
      'primary' => primary,
      'secondary' => secondary,
      'tertiary' => tertiary,
      'warning' => warning,
      'danger' => danger,
      _ => onSurfaceVariant,
    };
  }
}
