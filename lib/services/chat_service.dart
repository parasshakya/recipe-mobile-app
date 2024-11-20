import 'package:recipe_flutter_app/config/config.dart';
import 'package:recipe_flutter_app/models/chat_message.dart';
import 'package:recipe_flutter_app/models/chat_room.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;

  ChatService._internal();

  late IO.Socket socket;

  // Method to initialize the socket connection
  void initializeSocket(String userId) {
    // Initialize the connection to the socket server
    socket = IO.io(Config.serverUrl, <String, dynamic>{
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

    socket.on('private_message', (data) {
      print('Received private message: $data');
      // Handle received messages here (e.g., notify the UI)
    });

    socket.onConnectError((data) {
      print('Connection Error: $data');
    });
  }

  // Method to connect the socket manually
  void connectSocket() {
    if (!socket.connected) {
      socket.connect(); // Manually connect
    }
  }

  void joinChatRoom(String chatRoomId, String userId) {
    socket.emit("join_chat_room", {"chatRoomId": chatRoomId, "userId": userId});
  }

  void leaveChatRoom() {
    socket.emit("leave_chat_room");
  }

  // Method to send a message to the server
  void sendPrivateMessage(
      String tempId, String senderId, String recipientId, String message) {
    socket.emit('private_message', {
      "tempId": tempId,
      "senderId": senderId,
      'recipientId': recipientId,
      'message': message,
    });
  }

  void sendMessage(
      String tempId, String senderId, String chatRoomId, String message) {
    socket.emit('chat_message', {
      "tempId": tempId,
      "senderId": senderId,
      'chatRoomId': chatRoomId,
      'message': message,
    });
  }

  void onError(Function(String error) onError) {
    socket.on("error", (data) {
      final errorMessage = data["message"];
      onError(errorMessage);
    });
  }

  void onChatRoomUpdate(Function(ChatRoom chatRoom) onChatRoomUpdate) {
    print(" RECEIVED CHATROOM UDPATE");
    socket.on("chatRoom_update", (data) {
      final chatRoom = ChatRoom.fromJson(data["chatRoom"]);
      onChatRoomUpdate(chatRoom);
    });
  }

  void onMessageSent(
      Function(ChatMessage message, String tempId) onMessageSent) {
    socket.on("message_sent", (data) {
      print("ON MESSAGE SENT $data");
      final chatMessage = ChatMessage.fromJson(data["message"]);
      final tempId = data["tempId"];

      onMessageSent(chatMessage, tempId);
    });
  }

  void onMessageSeen(Function(ChatMessage message) onMessageSeen) {
    socket.on("message_seen", (data) {
      final chatMessage = ChatMessage.fromJson(data["message"]);
      onMessageSeen(chatMessage);
    });
  }

  void createSeenMessage(String chatRoomId, String readerId) {
    socket
        .emit("message_seen", {"chatRoomId": chatRoomId, "readerId": readerId});
  }

  // Listen for real-time incoming messages
  void onNewMessage(Function(ChatMessage message) onMessageReceived) {
    socket.on('receive_message', (data) {
      // Handle incoming messages
      final newMessage = ChatMessage.fromJson(data["message"]);
      onMessageReceived(newMessage);
    });
  }

  void onMessageDelivered(Function(ChatMessage message) onMessageDelivered) {
    socket.on('message_delivered', (data) {
      // Handle incoming messages
      final newMessage = ChatMessage.fromJson(data["message"]);
      onMessageDelivered(newMessage);
    });
  }

  // Disconnect the socket
  void disconnectSocket() {
    if (socket.connected) {
      socket.disconnect();
    }
  }

  // Method to handle cleanup
  void dispose() {
    socket.dispose();
  }
}
