import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/schemas/chat_message.dart';
import 'package:recipe_flutter_app/viewModels/chat_view_model.dart';
import 'package:recipe_flutter_app/viewModels/socket_view_model.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';

class PrivateChatScreen extends StatefulWidget {
  final String receiverUserId;
  const PrivateChatScreen({super.key, required this.receiverUserId});

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  final TextEditingController messageController = TextEditingController();
  late SocketViewModel socketViewModel;
  late ChatViewModel chatViewModel;
  late UserAuthViewModel userAuthViewModel;
  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    socketViewModel = Provider.of<SocketViewModel>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    userAuthViewModel = Provider.of<UserAuthViewModel>(context, listen: false);

    getMessages();

    socketViewModel.onNewMessage((newMessage) {
      setState(() {
        messages.add(newMessage);
      });
    });

    socketViewModel.onMessageSent((message, tempId) {
      setState(() {
        int index = messages.indexWhere((msg) => msg.id == tempId);
        if (index != -1) {
          messages[index] = message;
        }
      });
    });
  }

  Future<void> getMessages() async {
    final currentUserId = userAuthViewModel.currentUser!.id;

    final fetchedMessages =
        await chatViewModel.getMessages(currentUserId, widget.receiverUserId);
    setState(() {
      messages = fetchedMessages;
    });
  }

  void sendMessage() {
    final currentUserId = userAuthViewModel.currentUser!.id;
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

      socketViewModel.sendPrivateMessage(
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
                    decoration:
                        const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
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
        final isMe = message.senderId == userAuthViewModel.currentUser!.id;

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
