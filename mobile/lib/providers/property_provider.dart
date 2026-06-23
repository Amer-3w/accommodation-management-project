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
      // Pull master list ignoring backend parameters to filter 100% reliably locally
      final allItems = await _service!.list();

      properties = allItems.where((property) {
        if (search != null && search.isNotEmpty && search != 'All') {
          final keyword = search.toLowerCase();
          if (!property.propertyType.toLowerCase().contains(keyword) &&
              !property.title.toLowerCase().contains(keyword)) return false;
        }

        if (location != null && location.isNotEmpty) {
          final locKeyword = location.toLowerCase();
          final cityMatch =
              (property.city ?? '').toLowerCase().contains(locKeyword);
          final uniMatch =
              (property.university ?? '').toLowerCase().contains(locKeyword);
          final addrMatch =
              (property.address ?? '').toLowerCase().contains(locKeyword);
          final titleMatch = property.title.toLowerCase().contains(locKeyword);
          if (!cityMatch && !uniMatch && !addrMatch && !titleMatch)
            return false;
        }

        if (rooms != null && property.rooms != rooms) return false;
        if (minPrice != null && property.price < minPrice) return false;
        if (maxPrice != null && property.price > maxPrice) return false;

        if (propertyType != null && propertyType.isNotEmpty) {
          if (property.propertyType.toLowerCase() != propertyType.toLowerCase())
            return false;
        }

        if (rating != null && property.rating < rating) return false;

        if (amenities != null && amenities.isNotEmpty) {
          for (var amenity in amenities) {
            if (!property.amenities.contains(amenity)) return false;
          }
        }

        return true;
      }).toList();
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
