import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/studyhub_design.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/property_provider.dart';
import '../../widgets/studyhub_components.dart';
import '../booking/booking_screen.dart';
import '../chat/chat_screen.dart';
import '../owner/owner_profile_screen.dart';

class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({super.key});
  static const route = '/property';

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  int? propertyId;
  int imageIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)!.settings.arguments as int;
    if (propertyId != id) {
      propertyId = id;
      context.read<PropertyProvider>().open(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final property = context.watch<PropertyProvider>().selected;
    final favorites = context.watch<FavoriteProvider>();
    if (property == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final images = property.images;
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    SizedBox(
                      height: 286,
                      child: PageView(
                        onPageChanged: (value) => setState(() => imageIndex = value),
                        children: images.isEmpty
                            ? [Container(color: StudyHubColors.line, child: const Center(child: Icon(Icons.apartment, size: 70)))]
                            : images.map((url) => CachedNetworkImage(imageUrl: url, width: double.infinity, fit: BoxFit.cover)).toList(),
                      ),
                    ),
                    Positioned(top: 46, left: 16, child: _RoundAction(icon: Icons.arrow_back, onTap: () => Navigator.pop(context))),
                    Positioned(top: 46, right: 64, child: _RoundAction(icon: Icons.share_outlined, onTap: () {})),
                    Positioned(
                      top: 46,
                      right: 16,
                      child: _RoundAction(
                        icon: favorites.ids.contains(property.id) ? Icons.favorite : Icons.favorite_border,
                        color: favorites.ids.contains(property.id) ? StudyHubColors.error : StudyHubColors.darkGreen,
                        onTap: () => context.read<FavoriteProvider>().toggle(property),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.isEmpty ? 1 : images.length, (index) {
                          final selected = index == imageIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: selected ? 18 : 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(color: selected ? Colors.white : Colors.white60, borderRadius: BorderRadius.circular(8)),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 104),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(property.title, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.location_on_outlined, size: 18, color: StudyHubColors.secondaryText),
                        const SizedBox(width: 4),
                        Expanded(child: Text(property.location, style: const TextStyle(color: StudyHubColors.secondaryText))),
                      ]),
                      const SizedBox(height: 14),
                      Row(children: [
                        Text('\$${property.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: StudyHubColors.darkGreen)),
                        const Text('/month', style: TextStyle(color: StudyHubColors.secondaryText)),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(18)),
                          child: Row(children: [
                            const Icon(Icons.star, color: StudyHubColors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text('${property.rating.toStringAsFixed(1)}  (${property.reviewCount} reviews)', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                          ]),
                        ),
                      ]),
                      const SizedBox(height: 24),
                      const Text('Amenities', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.15,
                        children: property.amenities.map((amenity) {
                          return Container(
                            decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(13)),
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(_amenityIcon(amenity), color: StudyHubColors.darkGreen, size: 22),
                              const SizedBox(height: 8),
                              Text(amenity, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                            ]),
                          );
                        }).toList(),
                      ),
                      if (property.amenities.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text('No amenities listed yet.', style: TextStyle(color: StudyHubColors.secondaryText)),
                        ),
                      const SizedBox(height: 24),
                      const Text('Description', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      Text(property.description, style: const TextStyle(color: StudyHubColors.secondaryText, height: 1.5)),
                      const SizedBox(height: 24),
                      const Text('Owner Info', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(backgroundColor: StudyHubColors.darkGreen, child: Text(_initials(property.ownerName ?? 'Owner'), style: const TextStyle(color: Colors.white))),
                        title: Text(property.ownerName ?? 'Property Owner', style: const TextStyle(fontWeight: FontWeight.w900)),
                        subtitle: const Text('Property Owner'),
                        trailing: IconButton(icon: const Icon(Icons.call_outlined), onPressed: () => _openWhatsApp(context, property.ownerWhatsapp)),
                        onTap: () => Navigator.pushNamed(context, OwnerProfileScreen.route, arguments: property.ownerId),
                      ),
                      const Text('Map Preview', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => _openMap(context, property.latitude, property.longitude),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 120,
                          decoration: BoxDecoration(color: StudyHubColors.softGreen, borderRadius: BorderRadius.circular(16)),
                          child: const Center(child: Icon(Icons.location_pin, color: StudyHubColors.orange, size: 42)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Reviews', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      if (property.reviews.isEmpty)
                        const Text('No reviews yet.', style: TextStyle(color: StudyHubColors.secondaryText))
                      else
                        ...property.reviews.map((review) => Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(14)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(children: [
                                Text(review.userName, style: const TextStyle(fontWeight: FontWeight.w900)),
                                const Spacer(),
                                const Icon(Icons.star, color: StudyHubColors.orange, size: 16),
                                Text('${review.rating}'),
                              ]),
                              if ((review.createdAt ?? '').isNotEmpty)
                                Text(review.createdAt!, style: const TextStyle(color: StudyHubColors.secondaryText, fontSize: 11)),
                              if ((review.comment ?? '').isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(review.comment!, style: const TextStyle(fontSize: 12)),
                              ],
                              if ((review.ownerReply ?? '').isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text('Owner reply: ${review.ownerReply!}', style: const TextStyle(color: StudyHubColors.secondaryText, fontSize: 12)),
                              ],
                            ]),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 18,
            right: 18,
            bottom: 22,
            child: Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pushNamed(context, ChatScreen.route, arguments: property.ownerId), child: const Text('Chat'))),
                const SizedBox(width: 10),
                Expanded(child: StudyHubPrimaryButton(label: 'Book Now', onPressed: () => Navigator.pushNamed(context, BookingScreen.route, arguments: property.id))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _amenityIcon(String amenity) {
    final text = amenity.toLowerCase();
    if (text.contains('wifi')) return Icons.wifi;
    if (text.contains('parking')) return Icons.directions_car_outlined;
    if (text.contains('gym')) return Icons.fitness_center;
    if (text.contains('kitchen')) return Icons.restaurant_outlined;
    if (text.contains('ac')) return Icons.air;
    return Icons.check_circle_outline;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) return 'O';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

Future<void> _openWhatsApp(BuildContext context, String? number) async {
  if (number == null || !(number.startsWith('+970') || number.startsWith('+972'))) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('WhatsApp number is not available for this contact.')));
    return;
  }
  final normalized = number.replaceAll('+', '').replaceAll(' ', '');
  final uri = Uri.parse('https://wa.me/$normalized');
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp.')));
  }
}

Future<void> _openMap(BuildContext context, double? latitude, double? longitude) async {
  if (latitude == null || longitude == null) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Property location is not available.')));
    return;
  }
  final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$latitude,$longitude');
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open map.')));
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({required this.icon, required this.onTap, this.color = StudyHubColors.darkGreen});
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white,
      child: IconButton(icon: Icon(icon, color: color, size: 20), onPressed: onTap, padding: EdgeInsets.zero),
    );
  }
}
