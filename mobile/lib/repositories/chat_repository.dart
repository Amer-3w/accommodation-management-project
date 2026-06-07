import '../core/network/api_client.dart';

class ChatRepository {
  ChatRepository(this.api);

  final ApiClient api;

  Future<Map<String, dynamic>> messages(int receiverId) => api.get('/messages', query: {'receiver_id': '$receiverId'});
  Future<Map<String, dynamic>> send(int receiverId, String message) => api.post('/messages', {'receiver_id': receiverId, 'message': message});
  Future<Map<String, dynamic>> conversations() => api.get('/conversations');
}
