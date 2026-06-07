import 'package:flutter/foundation.dart';

import '../models/property.dart';
import '../services/property_service.dart';

class PropertyProvider extends ChangeNotifier {
  PropertyProvider.empty();

  PropertyService? _service;
  List<Property> properties = [];
  Property? selected;
  bool loading = false;
  String? error;

  void attach(PropertyService service) => _service = service;

  Future<void> load({
    String? search,
    String? location,
    int? rooms,
    double? minPrice,
    double? maxPrice,
    String? propertyType,
    List<String>? amenities,
    bool? availableOnly,
    double? rating,
    double? latitude,
    double? longitude,
    double? distance,
  }) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      properties = await _service!.list(
        search: search,
        location: location,
        rooms: rooms,
        minPrice: minPrice,
        maxPrice: maxPrice,
        propertyType: propertyType,
        amenities: amenities,
        availableOnly: availableOnly,
        rating: rating,
        latitude: latitude,
        longitude: longitude,
        distance: distance,
      );
    } catch (exception) {
      error = exception.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> open(int id) async {
    loading = true;
    notifyListeners();
    selected = await _service!.details(id);
    loading = false;
    notifyListeners();
  }
}
