import 'package:flutter/material.dart';

/// SimpleAppsPG Obsidian Minimalist Dark Mode Palette for ClimaNorm Pro
/// Zero network font dependencies; uses system platform typography for 100% offline reliability.
class AppColors {
  // Primary Canvas & Surfaces
  static const Color bgDark = Color(0xFF0B0F19); // Deep Slate Obsidian
  static const Color surfaceDark = Color(0xFF111827);
  static const Color surfaceCard = Color(0xFF161F30); // Elevated Slate Surface
  static const Color surfaceElevated = Color(0xFF1E293B);
  static const Color borderSubtle = Color(0xFF243046);
  static const Color borderHighContrast = Color(0xFF334155);

  // HVAC Accent & Normative Compliance Traffic Light Indicators
  static const Color iceBlue = Color(0xFF38BDF8); // Primary HVAC Cooling Ice Blue
  static const Color iceBlueDark = Color(0xFF0284C7);
  static const Color compliant = Color(0xFF00E676); // Optimal / Normative Compliant Emerald Green
  static const Color caution = Color(0xFFFFD600); // Caution / Suboptimal Amber
  static const Color critical = Color(0xFFFF1744); // Overcharged / Undercharged / Overload Red

  // Refrigerant Cylinders Standard Color Coding
  static const Color r32Color = Color(0xFF38BDF8); // Sky Cyan (A2L)
  static const Color r410aColor = Color(0xFFF472B6); // Rose Pink
  static const Color r134aColor = Color(0xFF60A5FA); // Light Blue
  static const Color r404aColor = Color(0xFFFB923C); // Orange
  static const Color r22Color = Color(0xFF4ADE80); // Light Green

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
}

class AppTheme {
  static const Color primary = AppColors.iceBlue;
  static const Color primaryDark = AppColors.iceBlueDark;
  static const Color accent = AppColors.compliant;
  static const Color success = AppColors.compliant;
  static const Color warning = AppColors.caution;
  static const Color error = AppColors.critical;

  static const Color darkBg = AppColors.bgDark;
  static const Color darkSurface = AppColors.surfaceDark;
  static const Color darkCard = AppColors.surfaceCard;
  static const Color darkBorder = AppColors.borderSubtle;

  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.iceBlue,
        secondary: AppColors.compliant,
        error: AppColors.critical,
        surface: AppColors.surfaceCard,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: AppColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgDark,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.iceBlue, width: 1.5),
        ),
        labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
      ),
    );
  }
}
