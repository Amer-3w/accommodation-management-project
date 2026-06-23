import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/EduStay_design.dart';
import '../../providers/property_provider.dart';
import '../../widgets/EduStay_components.dart';
import '../property/listings_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  static const route = '/search';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final location = TextEditingController();
  final minPrice = TextEditingController();
  final maxPrice = TextEditingController();
  int? rooms;
  double distance = 10;
  double rating = 0;
  bool availableOnly = false;
  final types = {
    'Apartment': false,
    'Studio': false,
    'Shared Room': false,
    'Dormitory': false
  };
  final amenities = {
    'WiFi': true,
    'Parking': false,
    'Gym': false,
    'Kitchen': false,
    'Laundry': false,
    'AC': false
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Filters')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 96),
        children: [
          const Text('Location',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Autocomplete<String>(
            optionsBuilder: (value) {
              final text = value.text.toLowerCase();
              if (text.isEmpty) return const Iterable<String>.empty();
              return PalestinianCities.values
                  .where((city) => city.toLowerCase().startsWith(text));
            },
            onSelected: (city) => location.text = city,
            fieldViewBuilder: (_, controller, focusNode, onSubmit) {
              controller.text = location.text;
              return TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: (value) => location.text = value,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on_outlined),
                    hintText: 'Enter city or area'),
              );
            },
          ),
          const SizedBox(height: 18),
          const Text('Price Range (\$/month)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: TextField(
                    controller: minPrice,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.attach_money),
                        hintText: 'Min'))),
            const SizedBox(width: 12),
            Expanded(
                child: TextField(
                    controller: maxPrice,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.attach_money),
                        hintText: 'Max'))),
          ]),
          const SizedBox(height: 18),
          const Text('Number of Rooms',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [null, 1, 2, 3, 4, 5].map((room) {
              final label = room == null
                  ? 'Any'
                  : room == 5
                      ? '5+'
                      : '$room';
              final selected = rooms == room;
              return _FilterBox(
                  label: label,
                  selected: selected,
                  onTap: () => setState(() => rooms = room));
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Property Type',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          ...types.keys.map((type) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: CheckboxListTile(
                  value: types[type],
                  onChanged: (value) =>
                      setState(() => types[type] = value ?? false),
                  title: Text(type,
                      style: const TextStyle(fontWeight: FontWeight.w800)),
                  tileColor: const Color(0xFFF7F8FA),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              )),
          const SizedBox(height: 8),
          const Text('Amenities',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: amenities.keys.map((amenity) {
              final selected = amenities[amenity]!;
              return FilterChip(
                selected: selected,
                label: Text(amenity),
                avatar: Icon(_amenityIcon(amenity), size: 15),
                onSelected: (value) =>
                    setState(() => amenities[amenity] = value),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          Text('Distance: ${distance.toStringAsFixed(0)} km',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          Slider(
              value: distance,
              min: 1,
              max: 50,
              onChanged: (value) => setState(() => distance = value)),
          Text('Minimum rating: ${rating.toStringAsFixed(1)}',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          Slider(
              value: rating,
              min: 0,
              max: 5,
              divisions: 10,
              onChanged: (value) => setState(() => rating = value)),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: availableOnly,
            onChanged: (value) => setState(() => availableOnly = value),
            title: const Text('Available only',
                style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(18),
        child: EduStayPrimaryButton(
          label: 'Apply Filters',
          onPressed: () async {
            await context.read<PropertyProvider>().load(
                  location: location.text,
                  rooms: rooms,
                  minPrice: double.tryParse(minPrice.text),
                  maxPrice: double.tryParse(maxPrice.text),
                  propertyType: _selectedPropertyType(),
                  amenities: amenities.entries
                      .where((e) => e.value)
                      .map((e) => e.key)
                      .toList(),
                  availableOnly: availableOnly,
                  rating: rating,
                  distance: distance,
                );
            if (context.mounted)
              Navigator.pushReplacementNamed(context, ListingsScreen.route);
          },
        ),
      ),
    );
  }

  IconData _amenityIcon(String text) {
    switch (text) {
      case 'WiFi':
        return Icons.wifi;
      case 'Parking':
        return Icons.directions_car;
      case 'Gym':
        return Icons.fitness_center;
      case 'Kitchen':
        return Icons.restaurant;
      case 'Laundry':
        return Icons.local_laundry_service;
      default:
        return Icons.ac_unit;
    }
  }

  String? _selectedPropertyType() {
    final selected = types.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
    return selected.isEmpty ? null : selected.first;
  }
}

class _FilterBox extends StatelessWidget {
  const _FilterBox(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 72,
        height: 44,
        decoration: BoxDecoration(
          color: selected ? EduStayColors.darkGreen : Colors.white,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
              color: selected ? EduStayColors.darkGreen : EduStayColors.line),
        ),
        child: Center(
            child: Text(label,
                style: TextStyle(
                    color: selected ? Colors.white : EduStayColors.text,
                    fontWeight: FontWeight.w900))),
      ),
    );
  }
}
