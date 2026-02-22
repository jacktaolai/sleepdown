import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF0061A4);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD1E4FF);
  static const Color onPrimaryContainer = Color(0xFF001D36);
  
  static const Color secondary = Color(0xFF535F70);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD7E3F7);
  static const Color onSecondaryContainer = Color(0xFF101C2B);
  
  static const Color tertiary = Color(0xFF6B5778);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFF2DAFF);
  static const Color onTertiaryContainer = Color(0xFF251431);
  
  static const Color surface = Color(0xFFFDFCFF);
  static const Color surfaceContainerLow = Color(0xFFF6F8FC);
  static const Color onSurface = Color(0xFF1A1C1E);
  static const Color surfaceVariant = Color(0xFFDFE2EB);
  static const Color onSurfaceVariant = Color(0xFF43474E);
  static const Color outline = Color(0xFF73777F);
  static const Color outlineVariant = Color(0xFFC3C7CF);

  // Card Colors
  static const Color cardPinkContainer = Color(0xFFFFD8E4);
  static const Color cardPinkOnContainer = Color(0xFF31111D);
  static const Color cardBlueContainer = Color(0xFFD1E4FF);
  static const Color cardBlueOnContainer = Color(0xFF001D36);
  static const Color cardPurpleContainer = Color(0xFFE8DEF8);
  static const Color cardPurpleOnContainer = Color(0xFF1D192B);
  static const Color cardGreenContainer = Color(0xFFBCECE0);
  static const Color cardGreenOnContainer = Color(0xFF00201A);
  static const Color cardIndigoContainer = Color(0xFFE0E0FF);
  static const Color cardIndigoOnContainer = Color(0xFF00006E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: onPrimary,
        primaryContainer: primaryContainer,
        onPrimaryContainer: onPrimaryContainer,
        secondary: secondary,
        onSecondary: onSecondary,
        secondaryContainer: secondaryContainer,
        onSecondaryContainer: onSecondaryContainer,
        tertiary: tertiary,
        onTertiary: onTertiary,
        tertiaryContainer: tertiaryContainer,
        onTertiaryContainer: onTertiaryContainer,
        error: Color(0xFFBA1A1A),
        onError: Color(0xFFFFFFFF),
        errorContainer: Color(0xFFFFDAD6),
        onErrorContainer: Color(0xFF410002),
        surface: surface,
        onSurface: onSurface,
        surfaceContainerLow: surfaceContainerLow,
        surfaceContainerHighest: surfaceVariant,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
      ),
      scaffoldBackgroundColor: surfaceContainerLow,
      fontFamily: 'Roboto', // Fallback to system font
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 57, height: 64/57, letterSpacing: -0.25),
        displayMedium: TextStyle(fontSize: 45, height: 52/45, letterSpacing: 0),
        displaySmall: TextStyle(fontSize: 36, height: 44/36, letterSpacing: 0),
        headlineLarge: TextStyle(fontSize: 32, height: 40/32, letterSpacing: 0),
        headlineMedium: TextStyle(fontSize: 28, height: 36/28, letterSpacing: 0),
        headlineSmall: TextStyle(fontSize: 24, height: 32/24, letterSpacing: 0),
        titleLarge: TextStyle(fontSize: 22, height: 28/22, letterSpacing: 0),
        titleMedium: TextStyle(fontSize: 16, height: 24/16, letterSpacing: 0.15, fontWeight: FontWeight.w500),
        titleSmall: TextStyle(fontSize: 14, height: 20/14, letterSpacing: 0.1, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(fontSize: 14, height: 20/14, letterSpacing: 0.1, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(fontSize: 12, height: 16/12, letterSpacing: 0.5, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(fontSize: 11, height: 16/11, letterSpacing: 0.5, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(fontSize: 16, height: 24/16, letterSpacing: 0.5),
        bodyMedium: TextStyle(fontSize: 14, height: 20/14, letterSpacing: 0.25),
        bodySmall: TextStyle(fontSize: 12, height: 16/12, letterSpacing: 0.4),
      ),
    );
  }
}
