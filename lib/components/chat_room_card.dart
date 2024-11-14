import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:recipe_flutter_app/models/chat_message.dart';
import 'package:recipe_flutter_app/models/chat_room.dart';
import 'package:recipe_flutter_app/models/user.dart';
import 'package:recipe_flutter_app/services/api_services.dart';
import 'package:recipe_flutter_app/services/chat_service.dart';

class ChatRoomCard extends StatefulWidget {
  final String recipientID;
  final ChatRoom chatRoom;
  const ChatRoomCard(
      {required this.chatRoom, required this.recipientID, super.key});

  @override
  State<ChatRoomCard> createState() => _ChatRoomCardState();
}

class _ChatRoomCardState extends State<ChatRoomCard> {
  User? recipient;
  bool loading = true;
  ChatRoom? chatRoom;
  final chatService = ChatService();

  fetchRecipient() async {
    recipient = await ApiService().getUserById(widget.recipientID);
    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    chatRoom = widget.chatRoom;
    fetchRecipient();
    chatService.onChatRoomUpdate((chatRoom) {
      if (mounted) {
        setState(() {
          this.chatRoom = chatRoom;
        });
      }
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? CircularProgressIndicator()
        : ListTile(
            title: Text(recipient!.username),
            leading: Image.network(recipient!.image),
            subtitle: Text(
              chatRoom!.lastMessage?.content ?? '',
              style: TextStyle(
                  fontWeight: chatRoom!.lastMessage?.senderId ==
                              recipient!.id &&
                          chatRoom!.lastMessage!.status != MessageStatus.seen
                      ? FontWeight.bold
                      : FontWeight.normal),
            ),
            trailing: Text(
              DateFormat('MMM d, yyyy h:mm a')
                  .format(chatRoom!.lastMessageTime.toLocal()),
            ),
          );
  }
}
