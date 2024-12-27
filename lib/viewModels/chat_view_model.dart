import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/models/chat_model.dart';
import 'package:recipe_flutter_app/schemas/chat_message.dart';
import 'package:recipe_flutter_app/schemas/chat_room.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatModel chatModel;

  List<ChatRoom> _myChatRooms = [];

  ChatRoom? _chatRoomById;

  Response? _messagesFromChatRoomIdResponse;

  List<ChatMessage> _messages = [];

  String? messagesError;

  Response? get messagesFromChatRoomIdResponse =>
      _messagesFromChatRoomIdResponse;

  String? messagesFromChatRoomIdError;

  ChatRoom? get chatRoomById => _chatRoomById;

  List<ChatRoom> get myChatRooms => _myChatRooms;

  String? myChatRoomsError;
  String? chatRoomByIdError;

  ChatViewModel({required this.chatModel});

  getMyChatRooms() async {
    try {
      _myChatRooms = await chatModel.getMyChatRooms();
    } catch (e) {
      myChatRoomsError = "Something went wrong";
    }
    notifyListeners();
  }

  getChatRoomById(String chatRoomId) async {
    try {
      _chatRoomById = await chatModel.getChatRoom(chatRoomId);
    } catch (e) {
      chatRoomByIdError = "Something went wrong";
    }
    notifyListeners();
  }

  updateMessagesToDelivered(
      String chatRoomId, String chatMessageId, MessageStatus status) async {
    try {
      await chatModel.updateChatMessageToDelivered(
          chatRoomId, chatMessageId, status);
    } catch (e) {
      print(e);
    }
  }

  getMessagesFromChatRoom(String chatRoomId,
      {DateTime? beforeTimestamp, int limit = 20}) async {
    try {
      _messagesFromChatRoomIdResponse =
          await chatModel.getMessagesFromChatRoomId(chatRoomId,
              beforeTimestamp: beforeTimestamp, limit: limit);
      notifyListeners();
    } catch (e) {
      messagesFromChatRoomIdError = "Something went wrong";
    } finally {
      notifyListeners();
    }
  }

  getMessages(String senderId, String receiverId) async {
    try {
      _messages = await chatModel.getMessages(senderId, receiverId);
    } catch (e) {
      messagesError = "Something went wrong";
    }
    notifyListeners();
  }
}
