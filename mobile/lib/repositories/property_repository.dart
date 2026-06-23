import 'dart:io';

import '../core/network/api_client.dart';

class PropertyRepository {
  PropertyRepository(this.api);

  final ApiClient api;

  Future<Map<String, dynamic>> list(Map<String, String> query) =>
      api.get('/properties', query: query);
  Future<Map<String, dynamic>> mine() =>
      api.get('/properties', query: {'owner_id': 'me'});
  Future<Map<String, dynamic>> details(int id) => api.get('/properties/$id');
  Future<Map<String, dynamic>> create(Map<String, dynamic> body) =>
      api.post('/properties', body);
  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> body) =>
      api.put('/properties/$id', body);
  Future<Map<String, dynamic>> delete(int id) => api.delete('/properties/$id');
  Future<Map<String, dynamic>> uploadImage(int id, File file) =>
      api.upload('/properties/$id/images', file, field: 'path');
  Future<Map<String, dynamic>> deleteImage(int propertyId, int imageId) =>
      api.delete('/properties/$propertyId/images/$imageId');
}
