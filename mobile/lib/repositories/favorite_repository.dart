import '../core/network/api_client.dart';

class FavoriteRepository {
  FavoriteRepository(this.api);

  final ApiClient api;

  Future<Map<String, dynamic>> list() => api.get('/favorites');
  Future<Map<String, dynamic>> add(int propertyId) => api.post('/favorites', {'property_id': propertyId});
  Future<Map<String, dynamic>> deleteById(int favoriteId) => api.delete('/favorites/$favoriteId');
  Future<Map<String, dynamic>> toggle(int propertyId) => api.post('/favorites/toggle', {'property_id': propertyId});
}
