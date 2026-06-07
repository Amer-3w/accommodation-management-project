import '../models/property.dart';
import '../repositories/favorite_repository.dart';
import '../core/utils/json_parsers.dart';

class FavoriteService {
  FavoriteService(this._repository);

  final FavoriteRepository _repository;

  Future<List<Property>> list() async {
    final json = await _repository.list();
    return asListData(json)
        .whereType<Map<String, dynamic>>()
        .map((item) => Property.fromJson((item['property'] as Map<String, dynamic>?) ?? item))
        .toList();
  }

  Future<void> toggle(int propertyId) async {
    final json = await _repository.list();
    final items = asListData(json).whereType<Map<String, dynamic>>().toList();
    final existing = items.where((item) => parseInt((item['property'] as Map<String, dynamic>?)?['id'] ?? item['property_id']) == propertyId).toList();
    if (existing.isNotEmpty) {
      await _repository.deleteById(parseInt(existing.first['id']));
      return;
    }
    await _repository.add(propertyId);
  }
}
