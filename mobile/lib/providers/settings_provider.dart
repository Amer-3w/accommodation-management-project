import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  Locale locale = const Locale('en');
  ThemeMode themeMode = ThemeMode.light;
  bool bookingNotifications = true;
  bool paymentNotifications = true;
  bool chatNotifications = true;
  bool propertyNotifications = true;
  bool reviewNotifications = true;

  bool get isArabic => locale.languageCode == 'ar';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    locale = Locale(prefs.getString('settings_language') ?? 'en');
    themeMode = (prefs.getString('settings_theme') ?? 'light') == 'dark' ? ThemeMode.dark : ThemeMode.light;
    bookingNotifications = prefs.getBool('settings_booking_notifications') ?? true;
    paymentNotifications = prefs.getBool('settings_payment_notifications') ?? true;
    chatNotifications = prefs.getBool('settings_chat_notifications') ?? true;
    propertyNotifications = prefs.getBool('settings_property_notifications') ?? true;
    reviewNotifications = prefs.getBool('settings_review_notifications') ?? true;
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    locale = Locale(value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings_language', value);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode value) async {
    themeMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings_theme', value == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setPreference(String key, bool value) async {
    switch (key) {
      case 'booking':
        bookingNotifications = value;
        break;
      case 'payment':
        paymentNotifications = value;
        break;
      case 'chat':
        chatNotifications = value;
        break;
      case 'property':
        propertyNotifications = value;
        break;
      case 'review':
        reviewNotifications = value;
        break;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_${key}_notifications', value);
    notifyListeners();
  }
}
