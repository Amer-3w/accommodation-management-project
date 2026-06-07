import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/studyhub_design.dart';
import '../../providers/auth_provider.dart';
import '../profile/profile_screen.dart';
import 'admin_components.dart';
import 'admin_list_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  static const route = '/admin-dashboard';

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String selected = 'dashboard';
  bool collapsed = false;

  final items = const [
    AdminSidebarItem('dashboard', Icons.dashboard_outlined, 'Dashboard'),
    AdminSidebarItem('analytics', Icons.analytics_outlined, 'Reports / Analytics'),
    AdminSidebarItem('users', Icons.people_outline, 'Users'),
    AdminSidebarItem('owners', Icons.store_outlined, 'Owners'),
    AdminSidebarItem('properties', Icons.apartment_outlined, 'Properties'),
    AdminSidebarItem('bookings', Icons.calendar_month_outlined, 'Bookings'),
    AdminSidebarItem('payments', Icons.payments_outlined, 'Payments'),
    AdminSidebarItem('reviews', Icons.star_border, 'Reviews'),
    AdminSidebarItem('support', Icons.support_agent_outlined, 'Support Messages'),
    AdminSidebarItem('notifications', Icons.notifications_outlined, 'Notifications'),
    AdminSidebarItem('settings', Icons.settings_outlined, 'Settings / Profile'),
    AdminSidebarItem('logout', Icons.logout, 'Logout'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final sidebar = AdminSidebar(
      items: items,
      selected: selected,
      collapsed: collapsed,
      onToggle: () => setState(() => collapsed = !collapsed),
      onSelect: (value) => setState(() => selected = value),
      onLogout: _logout,
    );

    final content = Column(children: [
      AdminHeader(
        title: _title,
        adminName: user?.name ?? 'Admin',
        photoUrl: user?.profilePhotoUrl,
        onNotifications: () => setState(() => selected = 'notifications'),
        onLogout: _logout,
      ),
      Expanded(child: _content()),
    ]);

    return Scaffold(
      backgroundColor: StudyHubColors.background,
      body: Directionality.of(context) == TextDirection.rtl
          ? Row(children: [Expanded(child: content), sidebar])
          : Row(children: [sidebar, Expanded(child: content)]),
    );
  }

  String get _title => switch (selected) {
        'dashboard' => 'Admin Dashboard',
        'analytics' => 'Reports / Analytics',
        'users' => 'Users',
        'owners' => 'Owners',
        'properties' => 'Properties',
        'bookings' => 'Bookings',
        'payments' => 'Payments',
        'reviews' => 'Reviews',
        'support' => 'Support Messages',
        'notifications' => 'Notifications',
        'settings' => 'Settings / Profile',
        _ => 'Admin Dashboard',
      };

  Widget _content() {
    if (selected == 'settings') return const ProfileScreen();
    return AdminListScreen(embeddedMode: selected);
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }
}
