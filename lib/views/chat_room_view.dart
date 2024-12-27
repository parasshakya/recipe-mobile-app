import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/viewModels/chat_view_model.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';
import 'package:recipe_flutter_app/widgets/chat_room_card.dart';
import 'package:recipe_flutter_app/schemas/chat_room.dart';
import 'package:recipe_flutter_app/views/chat_view.dart';

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late ChatViewModel chatViewModel;
  List<ChatRoom> chatrooms = [];

  bool loading = true;

  getChatrooms() async {
    chatrooms = await chatViewModel.getMyChatRooms();
    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    getChatrooms();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("messages"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : chatrooms.isEmpty
              ? const Center(
                  child: Text("No chat rooms created"),
                )
              : ListView.builder(
                  itemCount: chatrooms.length,
                  itemBuilder: (context, index) {
                    final chatroom = chatrooms[index];
                    final currentUserId =
                        Provider.of<UserAuthViewModel>(context, listen: false)
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
