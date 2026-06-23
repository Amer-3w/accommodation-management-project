import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/EduStay_design.dart';
import '../../providers/auth_provider.dart';
import '../chat/inbox_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import 'owner_bookings_screen.dart';
import 'owner_payments_screen.dart';
import 'owner_properties_screen.dart';
import 'owner_property_form_screen.dart';
import 'owner_profile_screen.dart';
import 'owner_reviews_screen.dart';
import 'owner_tenants_screen.dart';

const _ownerModulesList = [
  _OwnerModule(Icons.analytics_outlined, 'Analytics'),
  _OwnerModule(Icons.apartment_outlined, 'Properties'),
  _OwnerModule(Icons.calendar_month_outlined, 'Bookings'),
  _OwnerModule(Icons.payments_outlined, 'Payments'),
  _OwnerModule(Icons.people_outline, 'Tenants'),
  _OwnerModule(Icons.chat_bubble_outline, 'Messages'),
  _OwnerModule(Icons.star_border, 'Reviews'),
  _OwnerModule(Icons.notifications_outlined, 'Notifications'),
  _OwnerModule(Icons.person_outline, 'Profile'),
];

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
              onTap: () => setState(() => selected = 'Profile'),
              child: Row(children: [
                user?.profilePhotoUrl == null
                    ? CircleAvatar(
                        radius: 24,
                        backgroundColor: EduStayColors.orange,
                        child: Text(
                            (user?.name ?? 'O').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900)))
                    : CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(user!.profilePhotoUrl!)),
                if (!collapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(user?.name ?? 'Owner',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontWeight: FontWeight.w900)),
                        const Text('Owner Dashboard',
                            style: TextStyle(
                                color: EduStayColors.secondaryText,
                                fontSize: 11)),
                      ])),
                ],
              ]),
            ),
          ),
          IconButton(
              onPressed: () => setState(() => collapsed = !collapsed),
              icon: Icon(collapsed ? Icons.chevron_right : Icons.chevron_left)),
          Expanded(
            child: ListView(
              children: _ownerModulesList.map((module) {
                final active = selected == module.label;
                return ListTile(
                  selected: active,
                  selectedTileColor: EduStayColors.softGreen,
                  leading: Icon(module.icon,
                      color: active
                          ? EduStayColors.orange
                          : EduStayColors.darkGreen),
                  title: collapsed
                      ? null
                      : Text(module.label,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: active
                                  ? EduStayColors.darkGreen
                                  : EduStayColors.text,
                              fontSize: 12)),
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
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', (_) => false);
                }
              },
              icon: const Icon(Icons.logout, color: EduStayColors.error),
            ),
          ),
        ]),
      ),
    );

    final mainContent = Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxAllowedWidth = constraints.maxWidth - 8;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SizedBox(
              width: maxAllowedWidth,
              child: _workArea(),
            ),
          );
        },
      ),
    );

    return Scaffold(
      backgroundColor: EduStayColors.background,
      appBar: AppBar(
          title: Text(selected),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(onPressed: _load, icon: const Icon(Icons.refresh))
          ]),
      body: Directionality.of(context) == TextDirection.rtl
          ? Row(children: [mainContent, sideMenu])
          : Row(children: [sideMenu, mainContent]),
      floatingActionButton: selected == 'Properties'
          ? FloatingActionButton.extended(
              backgroundColor: EduStayColors.orange,
              foregroundColor: Colors.white,
              onPressed: () =>
                  Navigator.pushNamed(context, OwnerPropertyFormScreen.route),
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
      'Bookings' => const OwnerBookingsScreen(),
      'Payments' => const OwnerPaymentsScreen(),
      'Tenants' => const OwnerTenantsScreen(),
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
                _OwnerMetric(
                    value: '${stats['properties'] ?? 0}',
                    label: 'Properties',
                    color: EduStayColors.darkGreen),
                _OwnerMetric(
                    value: '${stats['active_bookings'] ?? 0}',
                    label: 'Active Bookings',
                    color: EduStayColors.orange),
                _OwnerMetric(
                    value: '${stats['pending_bookings'] ?? 0}',
                    label: 'Pending',
                    color: EduStayColors.darkGreen),
                _OwnerMetric(
                    value: '\$${stats['revenue'] ?? 0}',
                    label: 'Revenue',
                    color: EduStayColors.orange),
                _OwnerMetric(
                    value: '${stats['reviews'] ?? 0}',
                    label: 'Reviews',
                    color: EduStayColors.darkGreen),
                _OwnerMetric(
                    value: '${stats['unread_messages'] ?? 0}',
                    label: 'Unread Messages',
                    color: EduStayColors.orange),
              ],
            ),
          ],
        ),
      );
}

class _OwnerModule {
  const _OwnerModule(this.icon, this.label);
  final IconData icon;
  final String label;
}

class _OwnerMetric extends StatelessWidget {
  const _OwnerMetric(
      {required this.value, required this.label, required this.color});
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
        decoration: BoxDecoration(
            color: color, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900)),
          const Spacer(),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ]),
      ),
    );
  }
}

class _SimpleOwnerModule extends StatelessWidget {
  const _SimpleOwnerModule({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              title == 'Bookings'
                  ? Icons.calendar_month_outlined
                  : title == 'Payments'
                      ? Icons.payments_outlined
                      : Icons.people_outline,
              size: 48,
              color: EduStayColors.secondaryText.withOpacity(0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'No Active $title Found',
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: EduStayColors.darkGreen),
            ),
            const SizedBox(height: 4),
            Text(
              'Your rental profile has no records registered under this management section.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: EduStayColors.secondaryText, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
