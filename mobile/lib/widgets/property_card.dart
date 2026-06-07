import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../features/property/property_details_screen.dart';
import '../models/property.dart';

class PropertyCard extends StatelessWidget {
  const PropertyCard({required this.property, super.key});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final image = property.images.isNotEmpty ? property.images.first : null;
    return InkWell(
      onTap: () => Navigator.pushNamed(context, PropertyDetailsScreen.route, arguments: property.id),
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: image == null
                  ? Container(height: 150, color: const Color(0xFFE5E7EB), child: const Icon(Icons.apartment, size: 48))
                  : CachedNetworkImage(imageUrl: image, height: 150, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(property.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(property.location, style: const TextStyle(color: Color(0xFF6B7280))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text('\$${property.price.toStringAsFixed(0)}/mo', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                      const Spacer(),
                      const Icon(Icons.star, color: Color(0xFFF59E0B), size: 18),
                      Text(property.rating.toStringAsFixed(1)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
