import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/EduStay_design.dart';
import '../../models/property.dart';
import '../../widgets/EduStay_components.dart';
import '../chat/chat_screen.dart';
import '../property/property_details_screen.dart';

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});
  static const route = '/owner-profile';

  @override
  State<OwnerProfileScreen> createState() => _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
  Map<String, dynamic>? owner;
  List<Property> properties = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)!.settings.arguments as int;
    if (owner == null) _load(id);
  }

  Future<void> _load(int id) async {
    final response = await context.read<ApiClient>().get('/owners/$id');
    final data = response['data'] as Map<String, dynamic>;
    if (mounted) {
      setState(() {
        owner = data;
        properties = (data['properties'] as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(Property.fromJson)
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (owner == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final name = owner!['name']?.toString() ?? 'Owner';
    return Scaffold(
      appBar: AppBar(title: const Text('Owner Profile')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: EduStayColors.darkGreen,
                borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              CircleAvatar(
                  radius: 32,
                  backgroundColor: EduStayColors.orange,
                  child: Text(name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w900))),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(name,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 19)),
                    Text(
                        '${owner!['properties_count']} properties - ${owner!['reviews_count']} reviews',
                        style: const TextStyle(color: Colors.white70)),
                  ])),
              IconButton(
                  onPressed: () => Navigator.pushNamed(
                      context, ChatScreen.route, arguments: owner!['id']),
                  icon: const Icon(Icons.chat_bubble_outline,
                      color: Colors.white)),
            ]),
          ),
          const SizedBox(height: 18),
          const Text('Properties',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          if (properties.isEmpty)
            const Text('No active properties yet.',
                style: TextStyle(color: EduStayColors.secondaryText)),
          ...properties.map((property) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FigmaPropertyCard(
                    property: property,
                    onTap: () => Navigator.pushNamed(
                        context, PropertyDetailsScreen.route,
                        arguments: property.id)),
              )),
        ],
      ),
    );
  }
}
