import '../core/network/api_client.dart';

class BookingRepository {
  BookingRepository(this.api);

  final ApiClient api;

  Future<Map<String, dynamic>> list() => api.get('/bookings');
  Future<Map<String, dynamic>> details(int id) => api.get('/bookings/$id');
  Future<Map<String, dynamic>> create(Map<String, dynamic> body) => api.post('/bookings', body);
  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> body) => api.put('/bookings/$id', body);
  Future<Map<String, dynamic>> cancel(int id) => api.post('/booking/$id/cancel', {});
  Future<Map<String, dynamic>> delete(int id) => api.delete('/bookings/$id');
  Future<Map<String, dynamic>> status(int id, String status) => api.put('/booking/$id/status', {'status': status});
}
