import 'package:recipe_flutter_app/models/chat_message.dart';

class ChatRoom {
  final String id;
  final List<String> userIds;
  final DateTime lastMessageTime;
  final ChatMessage? lastMessage;

  ChatRoom({
    required this.id,
    required this.userIds,
    required this.lastMessage,
    required this.lastMessageTime,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json["_id"],
      lastMessage: json["lastMessage"] != null
          ? ChatMessage.fromJson(json["lastMessage"])
          : null,
      userIds: List<String>.from(json["userIds"]),
      lastMessageTime: DateTime.parse(json['lastMessageTime']),
    );
  }
}
