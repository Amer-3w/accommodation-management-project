import '../core/network/api_client.dart';

class NotificationRepository {
  NotificationRepository(this.api);

  final ApiClient api;

  Future<Map<String, dynamic>> list() => api.get('/notifications');
  Future<Map<String, dynamic>> markAllRead() => api.post('/notifications/mark-all-read', {});
}
