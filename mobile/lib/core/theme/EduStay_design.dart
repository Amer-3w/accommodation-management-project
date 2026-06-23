import 'package:flutter/material.dart';

class EduStayColors {
  static const darkGreen = Color(0xFF0C4A4A);
  static const orange = Color(0xFFF2A35B);
  static const success = Color(0xFF22C55E);
  static const error = Color(0xFFEF4444);
  static const background = Color(0xFFF8FAFC);
  static const card = Color(0xFFFFFFFF);
  static const text = Color(0xFF111827);
  static const secondaryText = Color(0xFF6B7280);
  static const line = Color(0xFFE5E7EB);
  static const softGreen = Color(0xFFE6F4F1);
  static const softOrange = Color(0xFFFFF2E8);
}

class EduStaySpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

class EduStayRadii {
  static const sm = 10.0;
  static const md = 14.0;
  static const lg = 18.0;
  static const xl = 28.0;
}

class EduStayIconSizes {
  static const small = 18.0;
  static const medium = 22.0;
  static const large = 28.0;
  static const xLarge = 44.0;
}

class EduStayShadows {
  static List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> soft = [
    BoxShadow(
      color: Colors.black.withOpacity(0.035),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
}

class PalestinianCities {
  static const values = [
    'Jerusalem',
    'Ramallah',
    'Nablus',
    'Jenin',
    'Tulkarm',
    'Qalqilya',
    'Bethlehem',
    'Hebron',
    'Jericho',
    'Salfit',
    'Tubas',
    'Gaza',
    'Khan Yunis',
    'Rafah',
    'Deir al-Balah',
    'North Gaza',
  ];
}

enum PasswordStrength { short, suitable, strong }

PasswordStrength passwordStrength(String password) {
  final hasCapital = RegExp(r'[A-Z]').hasMatch(password);
  final hasNumber = RegExp(r'[0-9]').hasMatch(password);
  final hasSymbol = RegExp(r'[^A-Za-z0-9]').hasMatch(password);
  if (password.length < 8) return PasswordStrength.short;
  if (hasCapital && hasNumber && hasSymbol) return PasswordStrength.strong;
  return PasswordStrength.suitable;
}

String passwordStrengthLabel(PasswordStrength strength) {
  switch (strength) {
    case PasswordStrength.short:
      return 'Short';
    case PasswordStrength.suitable:
      return 'Suitable';
    case PasswordStrength.strong:
      return 'Strong';
  }
}

Color passwordStrengthColor(PasswordStrength strength) {
  switch (strength) {
    case PasswordStrength.short:
      return EduStayColors.error;
    case PasswordStrength.suitable:
      return EduStayColors.orange;
    case PasswordStrength.strong:
      return EduStayColors.success;
  }
}
