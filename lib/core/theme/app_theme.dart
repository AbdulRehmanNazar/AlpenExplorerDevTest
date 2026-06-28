// lib/core/theme/app_theme.dart
// ─────────────────────────────────────────────────────────────────────────────
// ACHTUNG: Diese Datei NICHT verändern!
// Der Entwickler muss diese Farben und Stile 1:1 verwenden.
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';

class AppTheme {
  // Primärfarben (Alpine Grün)
  static const Color primary       = Color(0xFF1D9E75);
  static const Color primaryDark   = Color(0xFF0F6E56);
  static const Color primaryLight  = Color(0xFFE1F5EE);

  // Sekundär
  static const Color secondary     = Color(0xFF378ADD);
  static const Color accent        = Color(0xFFBA7517); // Amber / Sonne
  static const Color error         = Color(0xFFA32D2D);

  // Hintergründe
  static const Color background    = Color(0xFFF5F7F5);
  static const Color surface       = Color(0xFFFFFFFF);
  static const Color border        = Color(0xFFE0E0DC);

  // Text
  static const Color textPrimary   = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5F5E5A);
  static const Color textMuted     = Color(0xFF9E9C96);

  // Wetter-spezifische Farben
  static const Color weatherSunny    = Color(0xFFFAEEDA);
  static const Color weatherRain     = Color(0xFFE6F1FB);
  static const Color weatherSnow     = Color(0xFFF0F4FF);
  static const Color weatherStorm    = Color(0xFFFCEBEB);

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: secondary,
      surface: surface,
      background: background,
      error: error,
    ),
    scaffoldBackgroundColor: background,
    fontFamily: 'Arial',
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontSize: 17, fontWeight: FontWeight.w500,
        color: textPrimary, fontFamily: 'Arial',
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: border, width: 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    textTheme: const TextTheme(
      displayLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: textPrimary),
      headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textPrimary),
      headlineMedium:TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: textPrimary),
      titleLarge:    TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textPrimary),
      titleMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
      bodyLarge:     TextStyle(fontSize: 15, color: textPrimary, height: 1.6),
      bodyMedium:    TextStyle(fontSize: 13, color: textSecondary, height: 1.5),
      bodySmall:     TextStyle(fontSize: 12, color: textMuted),
      labelSmall:    TextStyle(fontSize: 10, color: textMuted, letterSpacing: 0.5),
    ),
    dividerTheme: const DividerThemeData(color: border, thickness: 0.5),
  );
}
