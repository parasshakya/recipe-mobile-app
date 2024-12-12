import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/components/chat_room_card.dart';
import 'package:recipe_flutter_app/models/chat_room.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/screens/chat_screen.dart';
import 'package:recipe_flutter_app/screens/private_chat_screen.dart';
import 'package:recipe_flutter_app/services/api_services.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  List<ChatRoom> chatrooms = [];

  bool loading = true;

  getChatrooms() async {
    chatrooms = await ApiService().getMyChatRooms();
    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    getChatrooms();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("messages"),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : chatrooms.isEmpty
              ? Center(
                  child: Text("No chat rooms created"),
                )
              : ListView.builder(
                  itemCount: chatrooms.length,
                  itemBuilder: (context, index) {
                    final chatroom = chatrooms[index];
                    final currentUserId =
                        Provider.of<AuthProvider>(context, listen: false)
                            .currentUser!
                            .id;

                    final recipientId = chatroom.userIds
                        .firstWhere((element) => element != currentUserId);

                    return GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                    chatRoomId: chatroom.id,
                                  )));
                        },
                        child: ChatRoomCard(
                          chatRoom: chatroom,
                          recipientID: recipientId,
                        ));
                  }),
    );
  }
}
