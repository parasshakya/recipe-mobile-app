import 'package:recipe_flutter_app/config/config.dart';
import 'package:recipe_flutter_app/schemas/chat_message.dart';
import 'package:recipe_flutter_app/schemas/chat_room.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketModel {
  // Method to initialize the socket connection
  io.Socket initializeSocket(String userId) {
    // Initialize the connection to the socket server
    final socket = io.io(Config.localSocketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'query': {'userId': userId},
      'autoConnect': false,
    });

    // Set up event listeners
    socket.onConnect((_) {
      print('Connected to WebSocket');
    });

    socket.onDisconnect((_) {
      print('Disconnected from WebSocket');
    });

    socket.onConnectError((data) {
      print('Connection Error: $data');
    });

    return socket;
  }

  void joinChatRoom(String chatRoomId, String userId, io.Socket socket) {
    socket.emit("join_chat_room", {"chatRoomId": chatRoomId, "userId": userId});
  }

  void leaveChatRoom(io.Socket socket) {
    socket.emit("leave_chat_room");
  }

  // Method to send a message to the server
  void sendPrivateMessage(io.Socket socket, String tempId, String senderId,
      String recipientId, String message) {
    socket.emit('private_message', {
      "tempId": tempId,
      "senderId": senderId,
      'recipientId': recipientId,
      'message': message,
    });
  }

  void sendMessage(io.Socket socket, String tempId, String senderId,
      String chatRoomId, String message) {
    socket.emit('chat_message', {
      "tempId": tempId,
      "senderId": senderId,
      'chatRoomId': chatRoomId,
      'message': message,
    });
  }

  void onError(Function(String error) onError, io.Socket socket) {
    socket.on("error", (data) {
      final errorMessage = data["message"];
      onError(errorMessage);
    });
  }

  void onChatRoomUpdate(
      Function(ChatRoom chatRoom) onChatRoomUpdate, io.Socket socket) {
    print(" RECEIVED CHATROOM UDPATE");
    socket.on("chatRoom_update", (data) {
      final chatRoom = ChatRoom.fromJson(data["chatRoom"]);
      onChatRoomUpdate(chatRoom);
    });
  }

  void onMessageSent(Function(ChatMessage message, String tempId) onMessageSent,
      io.Socket socket) {
    socket.on("message_sent", (data) {
      print("ON MESSAGE SENT $data");
      final chatMessage = ChatMessage.fromJson(data["message"]);
      final tempId = data["tempId"];

      onMessageSent(chatMessage, tempId);
    });
  }

  void onMessageSeen(
      Function(ChatMessage message) onMessageSeen, io.Socket socket) {
    socket.on("message_seen", (data) {
      final chatMessage = ChatMessage.fromJson(data["message"]);
      onMessageSeen(chatMessage);
    });
  }

  void createSeenMessage(String chatRoomId, String readerId, io.Socket socket) {
    socket
        .emit("message_seen", {"chatRoomId": chatRoomId, "readerId": readerId});
  }

  // Listen for real-time incoming messages
  void onNewMessage(
      Function(ChatMessage message) onMessageReceived, io.Socket socket) {
    socket.on('receive_message', (data) {
      // Handle incoming messages
      final newMessage = ChatMessage.fromJson(data["message"]);
      onMessageReceived(newMessage);
    });
  }

  void onMessageDelivered(
      Function(ChatMessage message) onMessageDelivered, io.Socket socket) {
    socket.on('message_delivered', (data) {
      // Handle incoming messages
      final newMessage = ChatMessage.fromJson(data["message"]);
      onMessageDelivered(newMessage);
    });
  }

  // Disconnect the socket
  void disconnectSocket(io.Socket socket) {
    if (socket.connected) {
      socket.disconnect();
    }
  }

  // Method to handle cleanup
  void dispose(io.Socket socket) {
    socket.dispose();
  }
}
