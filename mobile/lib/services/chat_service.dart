import '../models/message.dart';
import '../repositories/chat_repository.dart';
import '../core/utils/json_parsers.dart';

class ChatService {
  ChatService(this._repository);

  final ChatRepository _repository;

  Future<List<ChatMessage>> messages(int receiverId) async {
    final json = await _repository.messages(receiverId);
    return asListData(json).whereType<Map<String, dynamic>>().map(ChatMessage.fromJson).toList();
  }

  Future<ChatMessage> send(int receiverId, String message) async {
    final json = await _repository.send(receiverId, message);
    return ChatMessage.fromJson(asMapData(json));
  }

  Future<List<Map<String, dynamic>>> conversations() async {
    final json = await _repository.conversations();
    return asListData(json).whereType<Map<String, dynamic>>().toList();
  }
}
