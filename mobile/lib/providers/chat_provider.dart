import 'package:flutter/foundation.dart';

import '../models/message.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider.empty();

  ChatService? _service;
  List<ChatMessage> messages = [];
  bool loading = false;

  void attach(ChatService service) => _service = service;

  Future<void> load(int receiverId, {bool silent = false}) async {
    if (!silent) {
      loading = true;
      notifyListeners();
    }
    messages = await _service!.messages(receiverId);
    loading = false;
    notifyListeners();
  }

  Future<void> send(int receiverId, String body) async {
    final sent = await _service!.send(receiverId, body);
    messages = [...messages, sent];
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> conversations() async {
    return _service!.conversations();
  }
}
