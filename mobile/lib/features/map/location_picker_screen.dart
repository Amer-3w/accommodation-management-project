import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/theme/studyhub_design.dart';
import '../../widgets/studyhub_components.dart';

class PickedLocation {
  const PickedLocation({required this.latitude, required this.longitude, required this.city});
  final double latitude;
  final double longitude;
  final String city;
}

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});
  static const route = '/location-picker';

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng selected = const LatLng(31.9522, 35.2332);
  String city = 'Ramallah';
  static const mapsEnabled = bool.fromEnvironment('GOOGLE_MAPS_ENABLED', defaultValue: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Location')),
      body: Stack(
        children: [
          if (mapsEnabled)
            GoogleMap(
              initialCameraPosition: CameraPosition(target: selected, zoom: 8),
              markers: {Marker(markerId: const MarkerId('selected'), position: selected)},
              onTap: (value) => setState(() => selected = value),
            )
          else
            Container(
              color: StudyHubColors.softGreen,
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Google Maps API keys are required for interactive picking. Select a Palestinian city now; real coordinates can be enabled with GOOGLE_MAPS_ENABLED=true after adding keys.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 18,
            right: 18,
            top: 16,
            child: Material(
              borderRadius: BorderRadius.circular(16),
              elevation: 6,
              child: Autocomplete<String>(
                optionsBuilder: (value) {
                  final text = value.text.toLowerCase();
                  if (text.isEmpty) return const Iterable<String>.empty();
                  return PalestinianCities.values.where((item) => item.toLowerCase().startsWith(text));
                },
                onSelected: (value) => setState(() => city = value),
                fieldViewBuilder: (_, controller, focusNode, onSubmit) => TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search Palestinian city'),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(18),
        child: StudyHubPrimaryButton(
          label: 'Use This Location',
          onPressed: () => Navigator.pop(context, PickedLocation(latitude: selected.latitude, longitude: selected.longitude, city: city)),
        ),
      ),
    );
  }
}
