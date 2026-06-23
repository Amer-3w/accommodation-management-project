import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/EduStay_design.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  static const route = '/settings';

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppBar(title: Text(settings.isArabic ? 'الإعدادات' : 'Settings')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _Section(
            title: settings.isArabic ? 'اللغة' : 'Language',
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'en', label: Text('English')),
                ButtonSegment(value: 'ar', label: Text('العربية')),
              ],
              selected: {settings.locale.languageCode},
              onSelectionChanged: (value) => settings.setLanguage(value.first),
            ),
          ),
          _Section(
            title: settings.isArabic ? 'المظهر' : 'Theme',
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (value) => settings.setThemeMode(value.first),
            ),
          ),
          _Section(
            title: settings.isArabic
                ? 'تفضيلات الإشعارات'
                : 'Notification Preferences',
            child: Column(children: [
              _SwitchRow(
                  label:
                      settings.isArabic ? 'الحجوزات' : 'Booking notifications',
                  value: settings.bookingNotifications,
                  onChanged: (value) =>
                      settings.setPreference('booking', value)),
              _SwitchRow(
                  label:
                      settings.isArabic ? 'المدفوعات' : 'Payment notifications',
                  value: settings.paymentNotifications,
                  onChanged: (value) =>
                      settings.setPreference('payment', value)),
              _SwitchRow(
                  label: settings.isArabic ? 'المحادثات' : 'Chat notifications',
                  value: settings.chatNotifications,
                  onChanged: (value) => settings.setPreference('chat', value)),
              _SwitchRow(
                  label:
                      settings.isArabic ? 'العقارات' : 'Property notifications',
                  value: settings.propertyNotifications,
                  onChanged: (value) =>
                      settings.setPreference('property', value)),
              _SwitchRow(
                  label:
                      settings.isArabic ? 'التقييمات' : 'Review notifications',
                  value: settings.reviewNotifications,
                  onChanged: (value) =>
                      settings.setPreference('review', value)),
            ]),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: EduStayShadows.soft),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          child,
        ]),
      );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow(
      {required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        value: value,
        onChanged: onChanged,
      );
}
