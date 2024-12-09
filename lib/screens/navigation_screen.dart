import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/screens/chat_room_screen.dart';
import 'package:recipe_flutter_app/screens/create_recipe_screen.dart';
import 'package:recipe_flutter_app/screens/home_screen.dart';
import 'package:recipe_flutter_app/screens/notification_screen.dart';
import 'package:recipe_flutter_app/services/chat_service.dart';
import 'package:recipe_flutter_app/services/push_notification_service.dart';
import 'package:recipe_flutter_app/utils.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late AuthProvider authProvider;

  List<Widget> _pages = [
    HomeScreen(),
    Text("SEARCH PAGE"),
    CreateRecipeScreen(),
    Text("SETTINGS"),
    Text("Profile")
  ];

  @override
  void initState() {
    PushNotificationService().init();
    initializeSocket();

    super.initState();
  }

  initializeSocket() {
    final currentUserId =
        Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
    final chatService = ChatService();
    chatService.initializeSocket(currentUserId);
    chatService.connectSocket();

    chatService.onError((error) {
      showSnackbar(error, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<AuthProvider>(context);
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Icon(
            Icons.food_bank_rounded,
            color: Colors.amber,
            size: 35,
          ),
          actions: [
            Stack(children: [
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  child: Text(
                      "${authProvider.currentUser?.notifications!.length ?? 0}"),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NotificationScreen(
                          notifications:
                              authProvider.currentUser!.notifications!)));
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.notifications),
                ),
              )
            ]),
            SizedBox(
              width: 20,
            ),
            GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ChatRoomScreen()));
                },
                child: Icon(Icons.message_rounded)),
            SizedBox(
              width: 20,
            )
          ],
        ),
        body: TabBarView(
          children: [..._pages],
        ),
        bottomNavigationBar: TabBar(
          padding: EdgeInsets.only(top: 10),
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.transparent,
          tabs: [
            Tab(
              icon: Icon(
                Icons.home,
                size: 40,
              ),
            ),
            Tab(
              icon: Icon(Icons.search, size: 40),
            ),
            Tab(
              icon: Icon(Icons.add, size: 40),
            ),
            Tab(
              icon: Icon(Icons.settings, size: 40),
            ),
            Tab(icon: Image.network(authProvider.currentUser!.image)),
          ],
        ),
      ),
    );
  }
}
