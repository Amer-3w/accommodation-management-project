import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/studyhub_design.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../booking/bookings_dashboard_screen.dart';
import '../chat/inbox_screen.dart';
import '../favorites/favorites_screen.dart';
import '../home/home_screen.dart';
import '../map/map_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../property/listings_screen.dart';
import '../settings/settings_screen.dart';
import '../support/help_support_screen.dart';

class StudyHubShell extends StatefulWidget {
  const StudyHubShell({super.key, this.initialIndex = 0});
  static const route = '/app';

  final int initialIndex;

  @override
  State<StudyHubShell> createState() => _StudyHubShellState();
}

class _StudyHubShellState extends State<StudyHubShell> {
  late int index = widget.initialIndex;

  final pages = const [
    HomeScreen(embedded: true),
    ListingsScreen(embedded: true),
    MapScreen(embedded: true),
    BookingsDashboardScreen(embedded: true),
    ProfileScreen(embedded: true),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _StudyHubDrawer(onSelect: _handleDrawerRoute),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        child: KeyedSubtree(key: ValueKey(index), child: pages[index]),
      ),
      bottomNavigationBar: NavigationBar(
        height: 70,
        backgroundColor: Colors.white,
        indicatorColor: StudyHubColors.softGreen,
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.apartment_outlined), selectedIcon: Icon(Icons.apartment), label: 'Properties'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), selectedIcon: Icon(Icons.calendar_month), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  void _handleDrawerRoute(String route) {
    Navigator.pop(context);
    switch (route) {
      case 'home':
        setState(() => index = 0);
        break;
      case 'properties':
        setState(() => index = 1);
        break;
      case 'map':
        setState(() => index = 2);
        break;
      case 'bookings':
        setState(() => index = 3);
        break;
      case 'profile':
        setState(() => index = 4);
        break;
      case 'messages':
        Navigator.pushNamed(context, InboxScreen.route);
        break;
      case 'notifications':
        Navigator.pushNamed(context, NotificationsScreen.route);
        break;
      case 'favorites':
        Navigator.pushNamed(context, FavoritesScreen.route);
        break;
      case 'reviews':
        Navigator.pushNamed(context, MyReviewsScreen.route);
        break;
      case 'settings':
        Navigator.pushNamed(context, SettingsScreen.route);
        break;
      case 'help':
      case 'contact':
        Navigator.pushNamed(context, HelpSupportScreen.route);
        break;
      case 'about':
        showAboutDialog(
          context: context,
          applicationName: 'StudyHub',
          applicationVersion: '1.0.0',
          children: const [Text('Student accommodation platform.')],
        );
        break;
      case 'facebook':
        _openExternal('https://www.facebook.com');
        break;
      case 'instagram':
        _openExternal('https://www.instagram.com');
        break;
      case 'whatsapp':
        _openExternal('https://wa.me/972599776965');
        break;
      case 'linkedin':
        _openExternal('https://www.linkedin.com');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${route[0].toUpperCase()}${route.substring(1)} is ready for setup.')));
    }
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open link.')));
    }
  }
}

class _StudyHubDrawer extends StatelessWidget {
  const _StudyHubDrawer({required this.onSelect});

  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final unread = context.watch<NotificationProvider>().unreadCount;
    final items = [
      ('home', Icons.home_outlined, 'Home'),
      ('properties', Icons.apartment_outlined, 'Properties'),
      ('map', Icons.map_outlined, 'Map'),
      ('bookings', Icons.calendar_month_outlined, 'Bookings'),
      ('messages', Icons.chat_bubble_outline, 'Messages'),
      ('notifications', Icons.notifications_outlined, 'Notifications'),
      ('favorites', Icons.favorite_border, 'Favorites'),
      ('reviews', Icons.star_border, 'Reviews'),
      ('profile', Icons.person_outline, 'Profile'),
      ('settings', Icons.settings_outlined, 'Settings'),
      ('help', Icons.help_outline, 'Help'),
      ('about', Icons.info_outline, 'About'),
      ('contact', Icons.mail_outline, 'Contact Us'),
    ];

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: StudyHubColors.darkGreen,
              child: Row(
                children: [
                  user?.profilePhotoUrl == null
                      ? CircleAvatar(radius: 27, backgroundColor: StudyHubColors.orange, child: Text((user?.name ?? 'S').substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)))
                      : CircleAvatar(radius: 27, backgroundImage: NetworkImage(user!.profilePhotoUrl!)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'StudyHub', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)),
                        Text(user?.email ?? 'Student Services', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close menu',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                children: [
                  ...items.map((item) => ListTile(
                        leading: Icon(item.$2, color: StudyHubColors.darkGreen, size: StudyHubIconSizes.medium),
                        title: Text(item.$3, style: const TextStyle(fontWeight: FontWeight.w700)),
                        trailing: item.$1 == 'notifications' && unread > 0 ? CircleAvatar(radius: 10, backgroundColor: StudyHubColors.error, child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 10))) : null,
                        onTap: () => onSelect(item.$1),
                      )),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Text('Social Media', style: TextStyle(color: StudyHubColors.secondaryText, fontWeight: FontWeight.w800)),
                  ),
                  ...[
                    ('facebook', Icons.facebook, 'Facebook'),
                    ('instagram', Icons.camera_alt_outlined, 'Instagram'),
                    ('whatsapp', Icons.call_outlined, 'WhatsApp'),
                    ('linkedin', Icons.business_center_outlined, 'LinkedIn'),
                  ].map((item) => ListTile(leading: Icon(item.$2, color: StudyHubColors.darkGreen), title: Text(item.$3), onTap: () => onSelect(item.$1))),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () async {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
