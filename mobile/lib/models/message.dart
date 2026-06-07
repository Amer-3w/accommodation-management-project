import '../core/utils/json_parsers.dart';

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,
  });

  final int id;
  final int senderId;
  final int receiverId;
  final String message;
  final DateTime createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: parseInt(json['id']),
        senderId: parseInt(json['sender_id']),
        receiverId: parseInt(json['receiver_id']),
        message: parseString(json['message']),
        createdAt: DateTime.parse(json['created_at']),
      );
}
