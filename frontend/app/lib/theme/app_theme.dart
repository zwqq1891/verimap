import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand color constants
  static const Color primaryColor = Color(0xFF005BBF);
  static const Color primaryContainerColor = Color(0xFF1A73E8);
  static const Color secondaryColor = Color(0xFF5E5E62);
  static const Color secondaryContainerColor = Color(0xFFE3E2E6);
  static const Color tertiaryColor = Color(0xFFBB1712);
  static const Color tertiaryContainerColor = Color(0xFFDF3429);
  static const Color errorColor = Color(0xFFBA1A1A);
  static const Color errorContainerColor = Color(0xFFFFDAD6);
  static const Color backgroundColor = Color(0xFFF8F9FA);
  static const Color surfaceColor = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5);
  static const Color surfaceContainer = Color(0xFFEDEEEF);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E4);
  
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF191C1D);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF414754);
  static const Color outline = Color(0xFF727785);
  static const Color outlineVariant = Color(0xFFC1C6D6);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.notoSansTc().fontFamily,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primaryColor,
        onPrimary: onPrimary,
        primaryContainer: primaryContainerColor,
        onPrimaryContainer: onPrimary,
        secondary: secondaryColor,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainerColor,
        onSecondaryContainer: Color(0xFF646468),
        tertiary: tertiaryColor,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainerColor,
        onTertiaryContainer: onTertiary,
        error: errorColor,
        onError: onError,
        errorContainer: errorContainerColor,
        onErrorContainer: Color(0xFF93000A),
        background: backgroundColor,
        onBackground: onBackground,
        surface: surfaceColor,
        onSurface: onSurface,
        surfaceVariant: surfaceContainerHighest,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withOpacity(0.04),
        titleTextStyle: GoogleFonts.notoSansTc(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
      cardTheme: CardTheme(
        color: surfaceColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: outlineVariant, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.notoSansTc(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: onSurfaceVariant,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: outlineVariant, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryContainerColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryContainerColor,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.notoSansTc(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: GoogleFonts.notoSansTc().fontFamily,
          fontSize: 57,
          fontWeight: FontWeight.w700,
          height: 64 / 57,
          letterSpacing: -0.02,
          color: onSurface,
        ),
        headlineLarge: TextStyle(
          fontFamily: GoogleFonts.notoSansTc().fontFamily,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 40 / 32,
          color: onSurface,
        ),
        headlineMedium: TextStyle(
          fontFamily: GoogleFonts.notoSansTc().fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          height: 36 / 28,
          color: onSurface,
        ),
        titleLarge: TextStyle(
          fontFamily: GoogleFonts.notoSansTc().fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w500,
          height: 28 / 22,
          color: onSurface,
        ),
        bodyLarge: TextStyle(
          fontFamily: GoogleFonts.notoSansTc().fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
          color: onSurface,
        ),
        bodyMedium: TextStyle(
          fontFamily: GoogleFonts.notoSansTc().fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 20 / 14,
          color: onSurface,
        ),
        labelLarge: TextStyle(
          fontFamily: GoogleFonts.notoSansTc().fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          letterSpacing: 0.1,
          color: onSurface,
        ),
        labelSmall: TextStyle(
          fontFamily: GoogleFonts.notoSansTc().fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          height: 16 / 11,
          letterSpacing: 0.5,
          color: onSurface,
        ),
      ),
    );
  }
}
