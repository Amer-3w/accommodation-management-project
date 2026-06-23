import 'package:flutter/material.dart';

import 'EduStay_design.dart';

class AppTheme {
  static const primary = EduStayColors.darkGreen;
  static const ink = EduStayColors.text;
  static const muted = EduStayColors.secondaryText;
  static const surface = EduStayColors.background;
  static const accent = EduStayColors.orange;

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: Colors.white,
        error: EduStayColors.error,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: ink,
        titleTextStyle:
            TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        hintStyle:
            const TextStyle(color: EduStayColors.secondaryText, fontSize: 13),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EduStayRadii.md),
          borderSide: const BorderSide(color: EduStayColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EduStayRadii.md),
          borderSide: const BorderSide(color: EduStayColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EduStayRadii.md),
          borderSide:
              const BorderSide(color: EduStayColors.darkGreen, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: EduStayColors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(EduStayRadii.md)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF3F4F6),
        selectedColor: EduStayColors.darkGreen,
        labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide.none,
      ),
    );
  }

  static ThemeData get dark {
    final theme = light;
    return theme.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
        primary: EduStayColors.orange,
        secondary: EduStayColors.darkGreen,
        surface: const Color(0xFF111827),
        error: EduStayColors.error,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFF111827),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
      ),
      cardColor: const Color(0xFF111827),
    );
  }
}
