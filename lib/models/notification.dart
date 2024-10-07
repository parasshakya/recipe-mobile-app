import 'package:recipe_flutter_app/models/user.dart';

class UserNotification {
  String id;
  String message;
  String createdAt;
  String fromUserId;
  bool isRead;
  NotificationType type;
  Map<String, dynamic> data;

  UserNotification(
      {required this.id,
      required this.type,
      required this.message,
      required this.createdAt,
      required this.fromUserId,
      required this.isRead,
      required this.data});

  factory UserNotification.fromJson(Map<String, dynamic> json) {
    return UserNotification(
        id: json["_id"],
        type: NotificationType.values
            .firstWhere((element) => element.name == json["type"]),
        message: json["message"],
        createdAt: json["createdAt"],
        fromUserId: json["fromUserId"],
        isRead: json["isRead"],
        data: json["data"]);
  }

  toJson() {
    return {
      "id": id,
      "type": type.name,
      "message": message,
      "createdAt": createdAt,
      "fromUserId": fromUserId,
      "isRead": isRead,
      "data": data
    };
  }
}

enum NotificationType { follow, like, comment }
