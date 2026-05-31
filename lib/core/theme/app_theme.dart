import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static Color surface = const Color(0xFFF7F9FC);
  static Color onSurface = const Color(0xFF191C1E);
  static Color onSurfaceVariant = const Color(0xFF52606D);
  static Color primary = const Color(0xFF006D37);
  static Color primaryContainer = const Color(0xFF2ECC71);
  static Color secondary = const Color(0xFF0F6CBD);
  static Color tertiary = const Color(0xFFC67B17);
  static Color warning = const Color(0xFFF59E0B);
  static Color danger = const Color(0xFFB42318);
  static Color surfaceContainerLowest = Colors.white;
  static Color surfaceContainerLow = const Color(0xFFF2F4F7);
  static Color surfaceContainer = const Color(0xFFECEFF3);
  static Color surfaceContainerHigh = const Color(0xFFDCE2E8);
  static Color surfaceContainerHighest = const Color(0xFFC9D3DD);

  static LinearGradient get primaryGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [primary, primaryContainer],
      );

  static void dynamicUpdate(bool isDark) {
    if (isDark) {
      surface = const Color(0xFF0A0C10);
      onSurface = const Color(0xFFE2E8F0);
      onSurfaceVariant = const Color(0xFF94A3B8);
      primary = const Color(0xFF00A859);
      primaryContainer = const Color(0xFF10B981);
      secondary = const Color(0xFF47A1EC);
      tertiary = const Color(0xFFEAB308);
      warning = const Color(0xFFFBBF24);
      danger = const Color(0xFFEF4444);
      surfaceContainerLowest = const Color(0xFF161920);
      surfaceContainerLow = const Color(0xFF1E222B);
      surfaceContainer = const Color(0xFF242936);
      surfaceContainerHigh = const Color(0xFF2D3342);
      surfaceContainerHighest = const Color(0xFF383F51);
    } else {
      surface = const Color(0xFFF7F9FC);
      onSurface = const Color(0xFF191C1E);
      onSurfaceVariant = const Color(0xFF52606D);
      primary = const Color(0xFF006D37);
      primaryContainer = const Color(0xFF2ECC71);
      secondary = const Color(0xFF0F6CBD);
      tertiary = const Color(0xFFC67B17);
      warning = const Color(0xFFF59E0B);
      danger = const Color(0xFFB42318);
      surfaceContainerLowest = Colors.white;
      surfaceContainerLow = const Color(0xFFF2F4F7);
      surfaceContainer = const Color(0xFFECEFF3);
      surfaceContainerHigh = const Color(0xFFDCE2E8);
      surfaceContainerHighest = const Color(0xFFC9D3DD);
    }
  }

  static ThemeData get lightTheme {
    final textTheme = TextTheme(
      displayLarge: GoogleFonts.manrope(
        color: const Color(0xFF191C1E),
        fontWeight: FontWeight.w800,
      ),
      displayMedium: GoogleFonts.manrope(
        color: const Color(0xFF191C1E),
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: GoogleFonts.manrope(
        color: const Color(0xFF191C1E),
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.manrope(
        color: const Color(0xFF191C1E),
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: GoogleFonts.inter(color: const Color(0xFF191C1E)),
      bodyMedium: GoogleFonts.inter(color: const Color(0xFF191C1E)),
      labelLarge: GoogleFonts.inter(
        color: const Color(0xFF52606D),
        fontWeight: FontWeight.w600,
      ),
      labelMedium: GoogleFonts.inter(
        color: const Color(0xFF52606D),
        fontWeight: FontWeight.w500,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      colorScheme: const ColorScheme.light(
        surface: Color(0xFFF7F9FC),
        onSurface: Color(0xFF191C1E),
        primary: Color(0xFF006D37),
        primaryContainer: Color(0xFF2ECC71),
        secondary: Color(0xFF0F6CBD),
        tertiary: Color(0xFFC67B17),
        error: Color(0xFFB42318),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF7F9FC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF2F4F7),
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
          borderSide: const BorderSide(color: Color(0xFF006D37)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
      ),
      textTheme: textTheme,
    );
  }

  static ThemeData get darkTheme {
    final textTheme = TextTheme(
      displayLarge: GoogleFonts.manrope(
        color: const Color(0xFFE2E8F0),
        fontWeight: FontWeight.w800,
      ),
      displayMedium: GoogleFonts.manrope(
        color: const Color(0xFFE2E8F0),
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: GoogleFonts.manrope(
        color: const Color(0xFFE2E8F0),
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.manrope(
        color: const Color(0xFFE2E8F0),
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: GoogleFonts.inter(color: const Color(0xFFE2E8F0)),
      bodyMedium: GoogleFonts.inter(color: const Color(0xFFE2E8F0)),
      labelLarge: GoogleFonts.inter(
        color: const Color(0xFF94A3B8),
        fontWeight: FontWeight.w600,
      ),
      labelMedium: GoogleFonts.inter(
        color: const Color(0xFF94A3B8),
        fontWeight: FontWeight.w500,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0A0C10),
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF0A0C10),
        onSurface: Color(0xFFE2E8F0),
        primary: Color(0xFF00A859),
        primaryContainer: Color(0xFF10B981),
        secondary: Color(0xFF47A1EC),
        tertiary: Color(0xFFEAB308),
        error: Color(0xFFEF4444),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF0A0C10),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E222B),
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
          borderSide: const BorderSide(color: Color(0xFF00A859)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
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
              color: Colors.black.withValues(alpha: 0.05),
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
