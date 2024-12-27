enum MessageStatus {
  pending,
  sent,
  delivered,
  seen,
  failed,
}

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final MessageStatus status;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.status = MessageStatus.pending,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json["_id"],
      senderId: json['senderId'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      status: MessageStatus.values
          .firstWhere((element) => element.name == json["status"]),
    );
  }

  toJson() {
    return {
      "_id": id,
      "senderId": senderId,
      "content": content,
      "timeStamp":
          timestamp.toIso8601String(), // Use ISO 8601 for consistent formatting
      "status": status.name
    };
  }
}
