import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/models/chat_message.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/services/api_services.dart';
import 'package:recipe_flutter_app/services/chat_service.dart';
import 'package:recipe_flutter_app/utils.dart';

class PrivateChatScreen extends StatefulWidget {
  final String receiverUserId;
  const PrivateChatScreen({super.key, required this.receiverUserId});

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final ChatService chatService = ChatService();
  final TextEditingController messageController = TextEditingController();
  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();

    getMessages();

    chatService.onNewMessage((newMessage) {
      setState(() {
        messages.add(newMessage);
      });
    });

    chatService.onMessageSent((message, tempId) {
      setState(() {
        int index = messages.indexWhere((msg) => msg.id == tempId);
        if (index != -1) {
          messages[index] = message;
        }
      });
    });
  }

  Future<void> getMessages() async {
    final currentUserId =
        Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
    final fetchedMessages =
        await ApiService().getMessages(currentUserId, widget.receiverUserId);
    setState(() {
      messages = fetchedMessages;
    });
  }

  void sendMessage() {
    final currentUserId =
        Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
    if (messageController.text.isNotEmpty) {
      final tempId = DateTime.now().toString();
      final newMessage = ChatMessage(
        id: tempId,
        senderId: currentUserId,
        content: messageController.text.trim(),
        timestamp: DateTime.now(),
        status: MessageStatus.pending,
      );

      setState(() {
        messages.add(newMessage);
      });

      chatService.sendPrivateMessage(
          tempId, currentUserId, widget.receiverUserId, newMessage.content);

      messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(child: buildMessageList()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessageList() {
    return ListView.builder(
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId ==
            Provider.of<AuthProvider>(context, listen: false).currentUser!.id;

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    message.content,
                    style: TextStyle(color: isMe ? Colors.white : Colors.black),
                  ),
                ),
                Text(
                  _getMessageStatusText(message.status),
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getMessageStatusText(MessageStatus status) {
    switch (status) {
      case MessageStatus.sent:
        return "Sent";
      case MessageStatus.delivered:
        return "Delivered";
      case MessageStatus.seen:
        return "Seen";
      case MessageStatus.failed:
        return "Failed";
      default:
        return "Sending...";
    }
  }
}
