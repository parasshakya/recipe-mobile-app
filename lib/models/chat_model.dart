import 'package:dio/dio.dart';
import 'package:recipe_flutter_app/config/config.dart';
import 'package:recipe_flutter_app/interceptors/app_interceptor.dart';
import 'package:recipe_flutter_app/schemas/chat_message.dart';
import 'package:recipe_flutter_app/schemas/chat_room.dart';

class ChatModel {
  late final Dio dio;

  ChatModel() {
    dio = Dio(BaseOptions(
      baseUrl: Config.localBaseUrl,
      connectTimeout: const Duration(seconds: 10), // 10 seconds
      receiveTimeout: const Duration(seconds: 15), // 15 seconds
    ));
    dio.interceptors.add(AppInterceptor(dio: dio));
  }

  Future<List<ChatRoom>> getMyChatRooms() async {
    final response = await dio.get("/chatRooms");
    if (response.statusCode != 200) {
      throw Exception("Something went wrong");
    }
    final data = response.data;
    final chatRooms = data['chatRooms'] as List;

    return chatRooms.map((e) => ChatRoom.fromJson(e)).toList();
  }

  Future<Response> getMessagesFromChatRoomId(String chatroomId,
      {DateTime? beforeTimestamp, int limit = 20}) async {
    final response = await dio.get("/chatMessages", queryParameters: {
      "limit": limit,
      "chatRoomId": chatroomId,
      if (beforeTimestamp != null) "before": beforeTimestamp.toIso8601String()
    });
    if (response.statusCode != 200) {
      throw Exception("Something went wrong");
    }
    return response;
  }

  Future<ChatRoom> getChatRoom(String chatRoomId) async {
    final response = await dio.get("/chatRooms/$chatRoomId");

    if (response.statusCode != 200) {
      throw Exception("Something went wrong");
    }

    final data = response.data;
    final chatRoom = data["chatRoom"];
    return ChatRoom.fromJson(chatRoom);
  }

  Future<void> updateChatMessageToDelivered(
      String chatRoomId, String chatMessageId, MessageStatus status) async {
    final response = await dio.put("/chatMessages", data: {
      "chatRoomId": chatRoomId,
      "chatMessageId": chatMessageId,
      "status": status.name
    });
    if (response.statusCode != 200) {
      throw Exception("Something went wrong");
    }
  }

  Future<List<ChatMessage>> getMessages(
      String senderId, String receiverId) async {
    final response = await dio.get("/chatMessages",
        queryParameters: {"senderId": senderId, "recipientId": receiverId});

    if (response.statusCode != 200) {
      throw Exception("error getting messages");
    }

    final data = response.data;
    final messages = data["messages"] as List;
    return messages.map((e) => ChatMessage.fromJson(e)).toList();
  }
}
