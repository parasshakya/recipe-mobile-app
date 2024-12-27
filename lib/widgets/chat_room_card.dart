import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/schemas/chat_message.dart';
import 'package:recipe_flutter_app/schemas/chat_room.dart';
import 'package:recipe_flutter_app/schemas/user.dart';
import 'package:recipe_flutter_app/viewModels/socket_view_model.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';

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
  late SocketViewModel socketViewModel;
  late UserAuthViewModel userAuthViewModel;

  fetchRecipient() async {
    recipient = await userAuthViewModel.getUserById(widget.recipientID);
    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    socketViewModel = Provider.of<SocketViewModel>(context, listen: false);
    userAuthViewModel = Provider.of<UserAuthViewModel>(context, listen: false);

    chatRoom = widget.chatRoom;
    fetchRecipient();
    socketViewModel.onChatRoomUpdate((chatRoom) {
      if (mounted) {
        setState(() {
          this.chatRoom = chatRoom;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const CircularProgressIndicator()
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
