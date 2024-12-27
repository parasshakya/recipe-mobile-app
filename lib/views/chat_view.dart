import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/schemas/chat_message.dart';
import 'package:recipe_flutter_app/schemas/user.dart';
import 'package:recipe_flutter_app/models/socket_model.dart';
import 'package:recipe_flutter_app/utils.dart';
import 'package:recipe_flutter_app/viewModels/chat_view_model.dart';
import 'package:recipe_flutter_app/viewModels/socket_view_model.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';

class ChatScreen extends StatefulWidget {
  final String chatRoomId;
  const ChatScreen({super.key, required this.chatRoomId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final SocketModel socketModel = SocketModel();
  final TextEditingController messageController = TextEditingController();
  List<ChatMessage> messages = [];
  User? recipient;
  ScrollController scrollController = ScrollController();
  bool loading = true;
  bool fetchMoreLoading = false;
  bool hasMore = false;
  DateTime? before;
  late UserAuthViewModel userAuthViewModel;
  late SocketViewModel socketViewModel;
  late ChatViewModel chatViewModel;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      //this state is when the app is in background
      socketViewModel.leaveChatRoom();
    } else if (state == AppLifecycleState.resumed) {
      //this state is when the app is in foreground
      final currentUserId = userAuthViewModel.currentUser!.id;

      socketViewModel.joinChatRoom(widget.chatRoomId, currentUserId);
      socketViewModel.createSeenMessage(widget.chatRoomId, currentUserId);
    }
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    socketViewModel.leaveChatRoom();
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void initState() {
    userAuthViewModel = Provider.of<UserAuthViewModel>(context, listen: false);
    socketViewModel = Provider.of<SocketViewModel>(context, listen: false);
    chatViewModel = Provider.of<ChatViewModel>(context, listen: false);
    initialize();
    WidgetsBinding.instance.addObserver(this);

    super.initState();
  }

  initialize() async {
    await fetchRecipient();
    await setupSocket();

    await getMessages();
    loading = false;

    scrollController.addListener(() {
      if (scrollController.position.pixels == 0 &&
          hasMore &&
          !fetchMoreLoading) {
        getMessages();
      }
    });

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
    final currentUserId = userAuthViewModel.currentUser!.id;

    socketViewModel.joinChatRoom(widget.chatRoomId, currentUserId);

    socketViewModel.createSeenMessage(widget.chatRoomId, currentUserId);

    socketViewModel.onNewMessage((newMessage) {
      if (mounted) {
        setState(() {
          messages.add(newMessage);
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToBottom();
      });
    });

    socketViewModel.onMessageSent((message, tempId) {
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

    socketViewModel.onMessageSeen((message) {
      if (mounted) {
        setState(() {
          int index =
              messages.indexWhere((element) => element.id == message.id);
          if (index != -1) {
            messages[index] = message;
          }
        });
      }
    });

    socketViewModel.onMessageDelivered((message) {
      if (mounted) {
        setState(() {
          int index =
              messages.indexWhere((element) => element.id == message.id);
          if (index != -1) {
            messages[index] = message;
          }
        });
      }
    });
  }

  Future<void> getMessages() async {
    try {
      setState(() {
        fetchMoreLoading = true;
      });
      final response = await chatViewModel
          .getMessagesFromChatRoom(widget.chatRoomId, beforeTimestamp: before);

      final data = response.data;
      final fetchedMessages = (data["messages"] as List)
          .map((e) => ChatMessage.fromJson(e))
          .toList();
      final hasMore = data["hasMore"];
      this.hasMore = hasMore;
      if (fetchedMessages.isNotEmpty) {
        before = fetchedMessages.first.timestamp;
      }
      messages.insertAll(0, fetchedMessages);

      setState(() {});
    } catch (e) {
      print("ERROR fetching messages");
      showSnackbar("error while fetching messages", context);
    } finally {
      setState(() {
        fetchMoreLoading = false;
      });
    }
  }

  fetchRecipient() async {
    final currentUserId = userAuthViewModel.currentUser!.id;

    final chatRoom = await chatViewModel.getChatRoomById(widget.chatRoomId);

    final recipientId =
        chatRoom.userIds.firstWhere((element) => element != currentUserId);
    recipient = await userAuthViewModel.getUserById(recipientId);
    setState(() {});
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

      if (mounted) {
        setState(() {
          messages.add(newMessage);
        });
      }
      socketViewModel.sendMessage(
          tempId, currentUserId, widget.chatRoomId, newMessage.content);

      messageController.clear();
      scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(recipient?.username ?? "loading..."),
              actions: const [
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
                if (fetchMoreLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                Expanded(child: buildMessageList()),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: const InputDecoration(
                              hintText: 'Type a message...'),
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
      controller: scrollController,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderId ==
            Provider.of<UserAuthViewModel>(context, listen: false)
                .currentUser!
                .id;

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
