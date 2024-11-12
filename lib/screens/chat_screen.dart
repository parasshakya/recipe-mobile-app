import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/models/chat_message.dart';
import 'package:recipe_flutter_app/models/chat_room.dart';
import 'package:recipe_flutter_app/models/user.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/services/api_services.dart';
import 'package:recipe_flutter_app/services/chat_service.dart';
import 'package:recipe_flutter_app/utils.dart';

class ChatScreen extends StatefulWidget {
  final ChatRoom chatRoom;
  const ChatScreen({super.key, required this.chatRoom});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService chatService = ChatService();
  final TextEditingController messageController = TextEditingController();
  List<ChatMessage> messages = [];
  User? recipient;
  ScrollController scrollController = ScrollController();
  bool loading = true;

  // @override
  // void dispose() {
  //   chatService.disconnectSocket();
  //   // TODO: implement dispose
  //   super.dispose();
  // }

  @override
  void initState() {
    initialize();

    super.initState();
  }

  initialize() async {
    await fetchRecipient();
    await setupSocket();

    await getMessages();
    loading = false;

    setState(() {});

    // Ensure the scrollToBottom is called after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollToBottom();
    });
  }

  scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.jumpTo(scrollController.position.maxScrollExtent);
    }
  }

  setupSocket() {
    final currentUserId =
        Provider.of<AuthProvider>(context, listen: false).currentUser!.id;

    chatService.createSeenMessage(widget.chatRoom.id, currentUserId);

    chatService.onNewMessage((newMessage) {
      if (mounted) {
        setState(() {
          messages.add(newMessage);
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    });

    chatService.onMessageSent((message, tempId) {
      if (mounted) {
        setState(() {
          int index = messages.indexWhere((msg) => msg.id == tempId);
          if (index != -1) {
            messages[index] = message;
          }
        });
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    });
  }

  Future<void> getMessages() async {
    final fetchedMessages =
        await ApiService().getMessagesFromChatRoomId(widget.chatRoom.id);
    setState(() {
      messages = fetchedMessages;
    });
  }

  fetchRecipient() async {
    final currentUserId =
        Provider.of<AuthProvider>(context, listen: false).currentUser!.id;

    final recipientId = widget.chatRoom.userIds
        .firstWhere((element) => element != currentUserId);
    recipient = await ApiService().getUserById(recipientId);
    setState(() {});
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

      if (mounted) {
        setState(() {
          messages.add(newMessage);
        });
      }
      chatService.sendMessage(
          tempId, currentUserId, widget.chatRoom.id, newMessage.content);

      messageController.clear();
      scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(recipient?.username ?? "loading..."),
              actions: [
                Icon(Icons.call),
                SizedBox(
                  width: 20,
                ),
                Icon(Icons.video_call_rounded),
                SizedBox(
                  width: 20,
                ),
                Icon(Icons.more_vert_outlined),
                SizedBox(
                  width: 10,
                )
              ],
            ),
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
                              InputDecoration(hintText: 'Type a message...'),
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
      controller: scrollController,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId ==
            Provider.of<AuthProvider>(context, listen: false).currentUser!.id;

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                if (isMe)
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
