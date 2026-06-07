import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/studyhub_design.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/property_provider.dart';
import '../../widgets/studyhub_components.dart';
import '../chat/chatbot_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import '../property/listings_screen.dart';
import '../property/property_details_screen.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.embedded = false});
  static const route = '/home';

  final bool embedded;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'All';
  final categories = const [
    ('All', Icons.home_work_outlined),
    ('Apartment', Icons.apartment),
    ('Studio', Icons.weekend_outlined),
    ('Shared', Icons.groups_outlined),
    ('Dorm', Icons.school_outlined),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().load();
      context.read<FavoriteProvider>().load();
      context.read<NotificationProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final provider = context.watch<PropertyProvider>();
    final favorites = context.watch<FavoriteProvider>();
    final unread = context.watch<NotificationProvider>().unreadCount;
    final firstName = (user?.name.trim().isNotEmpty == true ? user!.name : 'Student').split(' ').first;

    final content = SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _HomeHeader(
                minHeight: 142,
                maxHeight: 142,
                child: Builder(builder: (context) {
                  return Container(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                    decoration: const BoxDecoration(
                      color: StudyHubColors.darkGreen,
                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StudyHubIconButton(icon: Icons.menu, onPressed: () => Scaffold.of(context).openDrawer(), selected: true),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Welcome back,', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  Text(firstName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                                ],
                              ),
                            ),
                            StudyHubIconButton(icon: Icons.notifications_outlined, badge: unread, onPressed: () => Navigator.pushNamed(context, NotificationsScreen.route)),
                            const SizedBox(width: 8),
                            InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () => Navigator.pushNamed(context, ProfileScreen.route),
                              child: user?.profilePhotoUrl == null
                                  ? CircleAvatar(radius: 22, backgroundColor: StudyHubColors.orange, child: Text((user?.name ?? 'S').substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)))
                                  : CircleAvatar(radius: 22, backgroundImage: NetworkImage(user!.profilePhotoUrl!)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, SearchScreen.route),
                          borderRadius: BorderRadius.circular(15),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                            child: const Row(children: [
                              Icon(Icons.search, color: StudyHubColors.secondaryText, size: 20),
                              SizedBox(width: 10),
                              Text('Search location or property...', style: TextStyle(color: StudyHubColors.secondaryText)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Transform.translate(
                      offset: const Offset(0, -10),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: StudyHubShadows.soft),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Categories', style: TextStyle(fontWeight: FontWeight.w900)),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 42,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: categories.map((item) {
                                  final selected = selectedCategory == item.$1;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      decoration: BoxDecoration(
                                        color: selected ? StudyHubColors.darkGreen : const Color(0xFFF5F6F7),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() => selectedCategory = item.$1);
                                          context.read<PropertyProvider>().load(search: item.$1 == 'All' ? null : item.$1);
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 13),
                                          child: Row(children: [
                                            Icon(item.$2, size: 16, color: selected ? Colors.white : StudyHubColors.darkGreen),
                                            const SizedBox(width: 7),
                                            Text(item.$1, style: TextStyle(color: selected ? Colors.white : StudyHubColors.text, fontWeight: FontWeight.w800, fontSize: 12)),
                                          ]),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Row(children: [
                      const Text('Featured', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      const Spacer(),
                      TextButton(onPressed: () => Navigator.pushNamed(context, ListingsScreen.route), child: const Text('See All')),
                    ]),
                    if (provider.loading) const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
                    ...provider.properties.asMap().entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: FadeSlideIn(
                            delay: Duration(milliseconds: entry.key * 55),
                            child: FigmaPropertyCard(
                              property: entry.value,
                              favorite: favorites.ids.contains(entry.value.id),
                              onFavorite: () => context.read<FavoriteProvider>().toggle(entry.value),
                              onTap: () => Navigator.pushNamed(context, PropertyDetailsScreen.route, arguments: entry.value.id),
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    final scaffold = Scaffold(
      appBar: null,
      body: content,
      floatingActionButton: FloatingActionButton(
        heroTag: 'home-chatbot',
        backgroundColor: StudyHubColors.orange,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.pushNamed(context, ChatbotScreen.route),
        child: const Icon(Icons.smart_toy_outlined),
      ),
    );
    return widget.embedded ? content : scaffold;
  }
}

class _HomeHeader extends SliverPersistentHeaderDelegate {
  _HomeHeader({required this.minHeight, required this.maxHeight, required this.child});
  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;

  @override
  bool shouldRebuild(covariant _HomeHeader oldDelegate) => maxHeight != oldDelegate.maxHeight || child != oldDelegate.child;
}
