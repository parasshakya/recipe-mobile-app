import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/models/chat_room.dart';
import 'package:recipe_flutter_app/models/user.dart';
import 'package:recipe_flutter_app/services/api_services.dart';

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

  fetchRecipient() async {
    recipient = await ApiService().getUserById(widget.recipientID);
    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    fetchRecipient();
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
            subtitle: Text(widget.chatRoom.lastMessage?.content ?? ''),
          );
  }
}
