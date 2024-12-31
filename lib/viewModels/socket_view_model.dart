import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/models/socket_model.dart';
import 'package:recipe_flutter_app/schemas/chat_message.dart';
import 'package:recipe_flutter_app/schemas/chat_room.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';

import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketViewModel extends ChangeNotifier {
  final SocketModel socketModel;

  io.Socket? socket;

  SocketViewModel({required this.socketModel});

  init() {
    final userViewModel = Provider.of<UserAuthViewModel>(
        navigatorKey.currentState!.context,
        listen: false);

    socket = socketModel.initializeSocket(userViewModel.currentUser!.id);
  }

  connect() {
    if (!socket!.connected) {
      socket = socket!.connect();
    }
  }

  disconnect() {
    if (socket!.connected) {
      socket = socket!.disconnect();
      notifyListeners();
    }
  }

  onNewMessage(Function(ChatMessage) onMessageReceived) {
    socketModel.onNewMessage((message) => onMessageReceived(message), socket!);
  }

  sendPrivateMessage(
      String tempId, String senderId, String recipientId, String message) {
    socketModel.sendPrivateMessage(
        socket!, tempId, senderId, recipientId, message);
  }

  void dispose() {
    socketModel.dispose(socket!);
  }

  onError(Function(String) onError) {
    socketModel.onError((error) => onError(error), socket!);
  }

  createSeenMessage(String chatRoomId, String readerId) {
    socketModel.createSeenMessage(chatRoomId, readerId, socket!);
  }

  joinChatRoom(String chatRoomId, String userId) {
    socketModel.joinChatRoom(chatRoomId, userId, socket!);
  }

  sendMessage(
      String tempId, String senderId, String chatRoomId, String message) {
    socketModel.sendMessage(socket!, tempId, senderId, chatRoomId, message);
  }

  leaveChatRoom() {
    socketModel.leaveChatRoom(socket!);
  }

  onChatRoomUpdate(Function(ChatRoom) onChatRoomUpdate) {
    socketModel.onChatRoomUpdate(
        (chatRoom) => onChatRoomUpdate(chatRoom), socket!);
  }

  onMessageDelivered(Function(ChatMessage) onMessageDelivered) {
    socketModel.onMessageDelivered(
        (message) => onMessageDelivered(message), socket!);
  }

  onMessageSeen(Function(ChatMessage) onMessageSeen) {
    socketModel.onMessageSeen((message) => onMessageSeen(message), socket!);
  }

  onMessageSent(
    Function(ChatMessage, String) onMessageSent,
  ) {
    socketModel.onMessageSent(
        (message, tempId) => onMessageSent(message, tempId), socket!);
  }
}
