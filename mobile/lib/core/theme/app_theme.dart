import 'package:flutter/material.dart';

import 'studyhub_design.dart';

class AppTheme {
  static const primary = StudyHubColors.darkGreen;
  static const ink = StudyHubColors.text;
  static const muted = StudyHubColors.secondaryText;
  static const surface = StudyHubColors.background;
  static const accent = StudyHubColors.orange;

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: surface,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: accent,
        surface: Colors.white,
        error: StudyHubColors.error,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: ink,
        titleTextStyle: TextStyle(color: ink, fontSize: 18, fontWeight: FontWeight.w900),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        hintStyle: const TextStyle(color: StudyHubColors.secondaryText, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StudyHubRadii.md),
          borderSide: const BorderSide(color: StudyHubColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StudyHubRadii.md),
          borderSide: const BorderSide(color: StudyHubColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(StudyHubRadii.md),
          borderSide: const BorderSide(color: StudyHubColors.darkGreen, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: StudyHubColors.orange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(StudyHubRadii.md)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF3F4F6),
        selectedColor: StudyHubColors.darkGreen,
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
        primary: StudyHubColors.orange,
        secondary: StudyHubColors.darkGreen,
        surface: const Color(0xFF111827),
        error: StudyHubColors.error,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Color(0xFF111827),
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
      ),
      cardColor: const Color(0xFF111827),
    );
  }
}
