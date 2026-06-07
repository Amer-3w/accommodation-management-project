import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../core/theme/studyhub_design.dart';
import '../../providers/property_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key, this.embedded = false});
  static const route = '/map';

  final bool embedded;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final search = TextEditingController();
  GoogleMapController? controller;
  static const palestineCenter = LatLng(31.9522, 35.2332);
  static const mapsEnabled = bool.fromEnvironment('GOOGLE_MAPS_ENABLED', defaultValue: false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<PropertyProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final properties = context.watch<PropertyProvider>().properties;
    if (!mapsEnabled) {
      return _MapsSetupFallback(
        embedded: widget.embedded,
        markerCount: properties.where((property) => property.latitude != null && property.longitude != null).length,
      );
    }
    final markers = properties
        .where((property) => property.latitude != null && property.longitude != null)
        .map((property) => Marker(
              markerId: MarkerId('property-${property.id}'),
              position: LatLng(property.latitude!, property.longitude!),
              infoWindow: InfoWindow(title: property.title, snippet: '\$${property.price.toStringAsFixed(0)}/month'),
            ))
        .toSet();

    return Scaffold(
      appBar: widget.embedded ? null : AppBar(title: const Text('Map')),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: const CameraPosition(target: palestineCenter, zoom: 8),
              markers: markers,
              myLocationButtonEnabled: true,
              zoomControlsEnabled: true,
              mapToolbarEnabled: true,
              onMapCreated: (mapController) => controller = mapController,
              onTap: (_) {},
            ),
            Positioned(
              left: 18,
              right: 18,
              top: 14,
              child: Material(
                elevation: 8,
                shadowColor: Colors.black12,
                borderRadius: BorderRadius.circular(16),
                child: Autocomplete<String>(
                  optionsBuilder: (value) {
                    final text = value.text.toLowerCase();
                    if (text.isEmpty) return const Iterable<String>.empty();
                    return PalestinianCities.values.where((city) => city.toLowerCase().startsWith(text));
                  },
                  onSelected: (city) {
                    search.text = city;
                    context.read<PropertyProvider>().load(location: city);
                  },
                  fieldViewBuilder: (_, textController, focusNode, onSubmit) => TextField(
                    controller: textController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search city or property location'),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 20,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: StudyHubShadows.card),
                child: Row(
                  children: [
                    const Icon(Icons.location_pin, color: StudyHubColors.orange),
                    const SizedBox(width: 10),
                    Expanded(child: Text('${markers.length} property locations visible')),
                    const Text('Clusters ready', style: TextStyle(color: StudyHubColors.secondaryText, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapsSetupFallback extends StatelessWidget {
  const _MapsSetupFallback({required this.embedded, required this.markerCount});

  final bool embedded;
  final int markerCount;

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, color: StudyHubColors.darkGreen, size: 72),
            const SizedBox(height: 18),
            const Text('Google Maps setup required', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Text(
              '$markerCount property marker(s) are ready. Add real Android/iOS Google Maps API keys, then run with --dart-define=GOOGLE_MAPS_ENABLED=true.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: StudyHubColors.secondaryText),
            ),
          ],
        ),
      ),
    );
    return Scaffold(appBar: embedded ? null : AppBar(title: const Text('Map')), body: content);
  }
}
