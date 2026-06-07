import '../core/network/api_client.dart';

class AdminRepository {
  AdminRepository(this.api);

  final ApiClient api;

  Future<Map<String, dynamic>> dashboard() => api.get('/admin/dashboard');
  Future<Map<String, dynamic>> analytics() => api.get('/admin/analytics');
  Future<Map<String, dynamic>> users() => api.get('/admin/users');
  Future<Map<String, dynamic>> owners() => api.get('/admin/owners');
  Future<Map<String, dynamic>> createUser(Map<String, dynamic> body) => api.post('/admin/users', body);
  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> body) => api.put('/admin/users/$id', body);
  Future<Map<String, dynamic>> deleteUser(int id) => api.delete('/admin/users/$id');
  Future<Map<String, dynamic>> bookings() => api.get('/admin/bookings');
  Future<Map<String, dynamic>> createBooking(Map<String, dynamic> body) => api.post('/admin/bookings', body);
  Future<Map<String, dynamic>> updateBooking(int id, Map<String, dynamic> body) => api.put('/admin/bookings/$id', body);
  Future<Map<String, dynamic>> deleteBooking(int id) => api.delete('/admin/bookings/$id');
  Future<Map<String, dynamic>> properties() => api.get('/admin/properties');
  Future<Map<String, dynamic>> createProperty(Map<String, dynamic> body) => api.post('/admin/properties', body);
  Future<Map<String, dynamic>> updateProperty(int id, Map<String, dynamic> body) => api.put('/admin/properties/$id', body);
  Future<Map<String, dynamic>> deleteAdminProperty(int id) => api.delete('/admin/properties/$id');
  Future<Map<String, dynamic>> payments() => api.get('/admin/payments');
  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> body) => api.post('/admin/payments', body);
  Future<Map<String, dynamic>> updatePayment(int id, Map<String, dynamic> body) => api.put('/admin/payments/$id', body);
  Future<Map<String, dynamic>> deletePayment(int id) => api.delete('/admin/payments/$id');
  Future<Map<String, dynamic>> reviews() => api.get('/admin/reviews');
  Future<Map<String, dynamic>> createReview(Map<String, dynamic> body) => api.post('/admin/reviews', body);
  Future<Map<String, dynamic>> updateReview(int id, Map<String, dynamic> body) => api.put('/admin/reviews/$id', body);
  Future<Map<String, dynamic>> deleteAdminReview(int id) => api.delete('/admin/reviews/$id');
  Future<Map<String, dynamic>> reports() => api.get('/admin/reports');
  Future<Map<String, dynamic>> notifications() => api.get('/admin/notifications');
  Future<Map<String, dynamic>> createNotification(Map<String, dynamic> body) => api.post('/admin/notifications', body);
  Future<Map<String, dynamic>> updateNotification(String id, Map<String, dynamic> body) => api.put('/admin/notifications/$id', body);
  Future<Map<String, dynamic>> deleteNotification(String id) => api.delete('/admin/notifications/$id');
  Future<Map<String, dynamic>> supportMessages() => api.get('/admin/support-messages');
  Future<Map<String, dynamic>> createSupportMessage(Map<String, dynamic> body) => api.post('/admin/support-messages', body);
  Future<Map<String, dynamic>> updateSupportMessage(int id, Map<String, dynamic> body) => api.put('/admin/support-messages/$id', body);
  Future<Map<String, dynamic>> deleteSupportMessage(int id) => api.delete('/admin/support-messages/$id');
  Future<Map<String, dynamic>> bookingStatus(int id, String status) => api.put('/booking/$id/status', {'status': status});
  Future<Map<String, dynamic>> deleteProperty(int id) => api.delete('/properties/$id');
  Future<Map<String, dynamic>> ownerReviews() => api.get('/owner/reviews');
  Future<Map<String, dynamic>> replyReview(int id, String reply) => api.post('/reviews/$id/reply', {'owner_reply': reply});
  Future<Map<String, dynamic>> deleteReview(int id) => api.delete('/reviews/$id');
}
