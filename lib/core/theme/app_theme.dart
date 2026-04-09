import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData light() {
    const scaffold = Color(0xFFF7F2EB);
    final scheme = const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF9E604B),
      onPrimary: Colors.white,
      secondary: Color(0xFF88B6A3),
      onSecondary: Color(0xFF0F1412),
      error: Color(0xFFD05C4E),
      onError: Colors.white,
      surface: Color(0xFFFFFCF8),
      onSurface: Color(0xFF1B1714),
      surfaceContainerHighest: Color(0xFFEDE2D7),
      onSurfaceVariant: Color(0xFF5B5148),
      outline: Color(0xFFD7C9BB),
      shadow: Color(0x1A000000),
      tertiary: Color(0xFFA78BD8),
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFE7DDF8),
      onTertiaryContainer: Color(0xFF2A1E3A),
      secondaryContainer: Color(0xFFD8EADF),
      onSecondaryContainer: Color(0xFF1C2B25),
      primaryContainer: Color(0xFFF0D9D0),
      onPrimaryContainer: Color(0xFF31150D),
      errorContainer: Color(0xFFFCD8D4),
      onErrorContainer: Color(0xFF410B07),
      surfaceDim: Color(0xFFE7DED5),
      surfaceBright: Color(0xFFFFFFFF),
      inverseSurface: Color(0xFF2E2926),
      onInverseSurface: Color(0xFFF8EFE7),
      inversePrimary: Color(0xFFFFB59B),
      surfaceTint: Color(0xFF9E604B),
      outlineVariant: Color(0xFFE6D9CC),
      scrim: Color(0x99000000),
    );
    return _buildTheme(
      scheme: scheme,
      scaffoldBackground: scaffold,
      cardColor: Colors.white.withValues(alpha: 0.84),
    );
  }

  static ThemeData dark() {
    const scaffold = Color(0xFF050505);
    final scheme = const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFCC7C62),
      onPrimary: Color(0xFF25100A),
      secondary: Color(0xFF8FD4BC),
      onSecondary: Color(0xFF082018),
      error: Color(0xFFFF8F84),
      onError: Color(0xFF3A0905),
      surface: Color(0xFF0B0B0B),
      onSurface: Color(0xFFF6F1EC),
      surfaceContainerHighest: Color(0xFF171717),
      onSurfaceVariant: Color(0xFFB9ADA1),
      outline: Color(0xFF2B2B2B),
      shadow: Colors.black,
      tertiary: Color(0xFFC9A9FF),
      onTertiary: Color(0xFF241138),
      tertiaryContainer: Color(0xFF241834),
      onTertiaryContainer: Color(0xFFEDDDFF),
      secondaryContainer: Color(0xFF10211C),
      onSecondaryContainer: Color(0xFFD7F4E8),
      primaryContainer: Color(0xFF311A14),
      onPrimaryContainer: Color(0xFFFFD7C9),
      errorContainer: Color(0xFF3D1110),
      onErrorContainer: Color(0xFFFFDAD6),
      surfaceDim: Color(0xFF090909),
      surfaceBright: Color(0xFF1C1C1C),
      inverseSurface: Color(0xFFF7EEE6),
      onInverseSurface: Color(0xFF211D1A),
      inversePrimary: Color(0xFF9E604B),
      surfaceTint: Color(0xFFCC7C62),
      outlineVariant: Color(0xFF232323),
      scrim: Color(0xCC000000),
    );
    return _buildTheme(
      scheme: scheme,
      scaffoldBackground: scaffold,
      cardColor: const Color(0xFF101010).withValues(alpha: 0.9),
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme scheme,
    required Color scaffoldBackground,
    required Color cardColor,
  }) {
    final textTheme = GoogleFonts.manropeTextTheme().copyWith(
      headlineLarge: GoogleFonts.cormorantGaramond(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.cormorantGaramond(
        fontSize: 32,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: GoogleFonts.cormorantGaramond(
        fontSize: 26,
        fontWeight: FontWeight.w700,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      titleMedium: GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: GoogleFonts.manrope(fontSize: 15, height: 1.4),
      bodyMedium: GoogleFonts.manrope(fontSize: 14, height: 1.5),
      labelLarge: GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );

    final radius = BorderRadius.circular(30);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shadowColor: scheme.shadow.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface.withValues(alpha: 0.8),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(26),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.75),
        selectedColor: scheme.tertiaryContainer,
        labelStyle: textTheme.labelLarge?.copyWith(color: scheme.onSurface),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface.withValues(alpha: 0.88),
        indicatorColor: scheme.primaryContainer.withValues(alpha: 0.8),
        labelTextStyle: WidgetStateProperty.all(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
