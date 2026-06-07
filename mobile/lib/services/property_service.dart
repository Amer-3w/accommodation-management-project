import '../models/property.dart';
import '../repositories/property_repository.dart';
import '../core/utils/json_parsers.dart';

class PropertyService {
  PropertyService(this._repository);

  final PropertyRepository _repository;

  Future<List<Property>> list({
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
    final query = <String, String>{
      if (search?.isNotEmpty == true) 'search': search!,
      if (location?.isNotEmpty == true) 'location': location!,
      if (rooms != null) 'rooms': rooms.toString(),
      if (minPrice != null) 'min_price': minPrice.toStringAsFixed(0),
      if (maxPrice != null) 'max_price': maxPrice.toStringAsFixed(0),
      if (propertyType?.isNotEmpty == true) 'property_type': propertyType!,
      if (amenities?.isNotEmpty == true) 'amenities': amenities!.join(','),
      if (availableOnly == true) 'available_only': '1',
      if (rating != null && rating > 0) 'rating': rating.toStringAsFixed(1),
      if (latitude != null) 'latitude': latitude.toString(),
      if (longitude != null) 'longitude': longitude.toString(),
      if (distance != null) 'distance': distance.toString(),
    };
    final json = await _repository.list(query);
    return asListData(json).whereType<Map<String, dynamic>>().map(Property.fromJson).toList();
  }

  Future<Property> details(int id) async {
    final json = await _repository.details(id);
    return Property.fromJson(asMapData(json));
  }
}
