import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/studyhub_design.dart';
import '../../providers/auth_provider.dart';
import '../chat/inbox_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import 'owner_properties_screen.dart';
import 'owner_property_form_screen.dart';
import 'owner_profile_screen.dart';
import 'owner_reviews_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});
  static const route = '/owner-dashboard';

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  Map<String, dynamic> stats = const {};
  bool loading = true;
  bool collapsed = false;
  String selected = 'Analytics';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final response = await context.read<ApiClient>().get('/owner/reports');
    if (mounted) {
      setState(() {
        stats = response['data'] as Map<String, dynamic>;
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final modules = const [
      _OwnerModule(Icons.analytics_outlined, 'Analytics'),
      _OwnerModule(Icons.apartment_outlined, 'Properties'),
      _OwnerModule(Icons.calendar_month_outlined, 'Bookings'),
      _OwnerModule(Icons.payments_outlined, 'Payments'),
      _OwnerModule(Icons.people_outline, 'Tenants'),
      _OwnerModule(Icons.chat_bubble_outline, 'Messages'),
      _OwnerModule(Icons.star_border, 'Reviews'),
      _OwnerModule(Icons.notifications_outlined, 'Notifications'),
      _OwnerModule(Icons.event_available_outlined, 'Availability'),
      _OwnerModule(Icons.location_on_outlined, 'Locations'),
      _OwnerModule(Icons.person_outline, 'Profile'),
    ];
    final user = context.watch<AuthProvider>().user;
    final sideMenu = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: collapsed ? 76 : 212,
      color: Colors.white,
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                if (user != null) Navigator.pushNamed(context, OwnerProfileScreen.route, arguments: user.id);
              },
              child: Row(children: [
                user?.profilePhotoUrl == null
                    ? CircleAvatar(radius: 24, backgroundColor: StudyHubColors.orange, child: Text((user?.name ?? 'O').substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)))
                    : CircleAvatar(radius: 24, backgroundImage: NetworkImage(user!.profilePhotoUrl!)),
                if (!collapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(user?.name ?? 'Owner', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const Text('Owner Dashboard', style: TextStyle(color: StudyHubColors.secondaryText, fontSize: 11)),
                  ])),
                ],
              ]),
            ),
          ),
          IconButton(onPressed: () => setState(() => collapsed = !collapsed), icon: Icon(collapsed ? Icons.chevron_right : Icons.chevron_left)),
          Expanded(
            child: ListView(
              children: modules.map((module) {
                final active = selected == module.label;
                return ListTile(
                  selected: active,
                  selectedTileColor: StudyHubColors.softGreen,
                  leading: Icon(module.icon, color: active ? StudyHubColors.orange : StudyHubColors.darkGreen),
                  title: collapsed ? null : Text(module.label, style: TextStyle(fontWeight: FontWeight.w800, color: active ? StudyHubColors.darkGreen : StudyHubColors.text, fontSize: 12)),
                  onTap: () => setState(() => selected = module.label),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: IconButton(
              tooltip: 'Logout',
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              },
              icon: const Icon(Icons.logout, color: StudyHubColors.error),
            ),
          ),
        ]),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(selected), automaticallyImplyLeading: false, actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: Directionality.of(context) == TextDirection.rtl
          ? Row(children: [Expanded(child: _workArea()), sideMenu])
          : Row(children: [sideMenu, Expanded(child: _workArea())]),
      floatingActionButton: selected == 'Properties'
          ? FloatingActionButton.extended(
              backgroundColor: StudyHubColors.orange,
              foregroundColor: Colors.white,
              onPressed: () => Navigator.pushNamed(context, OwnerPropertyFormScreen.route),
              icon: const Icon(Icons.add),
              label: const Text('Property'),
            )
          : null,
    );
  }

  Widget _workArea() {
    if (loading) return const Center(child: CircularProgressIndicator());
    return switch (selected) {
      'Properties' => const OwnerPropertiesScreen(embedded: true),
      'Messages' => const InboxScreen(),
      'Reviews' => const OwnerReviewsScreen(),
      'Notifications' => const NotificationsScreen(),
      'Profile' => const ProfileScreen(),
      'Bookings' || 'Payments' || 'Tenants' || 'Availability' || 'Locations' => _SimpleOwnerModule(title: selected),
      _ => _analytics(),
    };
  }

  Widget _analytics() => RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _OwnerMetric(value: '${stats['properties'] ?? 0}', label: 'Properties', color: StudyHubColors.darkGreen),
                _OwnerMetric(value: '${stats['active_bookings'] ?? 0}', label: 'Active Bookings', color: StudyHubColors.orange),
                _OwnerMetric(value: '${stats['pending_bookings'] ?? 0}', label: 'Pending', color: StudyHubColors.darkGreen),
                _OwnerMetric(value: '\$${stats['revenue'] ?? 0}', label: 'Revenue', color: StudyHubColors.orange),
                _OwnerMetric(value: '${stats['reviews'] ?? 0}', label: 'Reviews', color: StudyHubColors.darkGreen),
                _OwnerMetric(value: '${stats['unread_messages'] ?? 0}', label: 'Unread Messages', color: StudyHubColors.orange),
              ],
            ),
          ],
        ),
      );
}

class _SimpleOwnerModule extends StatelessWidget {
  const _SimpleOwnerModule({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Center(
        child: Text('$title data is available from the connected dashboard APIs.', style: const TextStyle(color: StudyHubColors.secondaryText)),
      );
}

class _OwnerModule {
  const _OwnerModule(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _OwnerMetric extends StatelessWidget {
  const _OwnerMetric({required this.value, required this.label, required this.color});
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 148,
      child: Container(
        height: 96,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
          const Spacer(),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ]),
      ),
    );
  }
}
