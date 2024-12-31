import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/viewModels/local_notification_view_model.dart';
import 'package:recipe_flutter_app/viewModels/push_notification_view_model.dart';
import 'package:recipe_flutter_app/viewModels/socket_view_model.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';
import 'package:recipe_flutter_app/views/chat_room_view.dart';
import 'package:recipe_flutter_app/views/create_recipe_view.dart';
import 'package:recipe_flutter_app/views/home_view.dart';
import 'package:recipe_flutter_app/views/notification_view.dart';
import 'package:recipe_flutter_app/views/profile_view.dart';
import 'package:recipe_flutter_app/views/search_view.dart';
import 'package:recipe_flutter_app/views/settings_view.dart';
import 'package:recipe_flutter_app/utils.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late UserAuthViewModel userAuthViewModel;
  late SocketViewModel socketViewModel;
  late PushNotificationViewModel pushNotificationViewModel;
  late LocalNotificationViewModel localNotificationViewModel;

  bool isUserProfileTab = false;

  final List<Widget> _pages = [
    const HomeScreen(),
    const SearchScreen(),
    CreateRecipeScreen(),
    SettingsScreen(),
    const ProfileScreen()
  ];

  @override
  void initState() {
    userAuthViewModel = Provider.of<UserAuthViewModel>(context, listen: false);
    socketViewModel = Provider.of<SocketViewModel>(context, listen: false);
    localNotificationViewModel =
        Provider.of<LocalNotificationViewModel>(context, listen: false);
    pushNotificationViewModel =
        Provider.of<PushNotificationViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      initializeNotifications();
      initializeSocket();
    });
    super.initState();
  }

  initializeNotifications() async {
    await pushNotificationViewModel.init();
    await localNotificationViewModel.init();
  }

  initializeSocket() {
    socketViewModel.init();
    socketViewModel.connect();
    socketViewModel.onError((error) {
      showSnackbar(error, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    userAuthViewModel = Provider.of<UserAuthViewModel>(context);
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Icon(
            Icons.food_bank_rounded,
            color: Colors.amber.shade700,
            size: 35,
          ),
          actions: [
            Stack(children: [
              Positioned(
                top: 0,
                right: 0,
                child: Text(
                    "${userAuthViewModel.currentUser?.notifications!.length ?? 0}"),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => NotificationScreen(
                          notifications:
                              userAuthViewModel.currentUser!.notifications!)));
                },
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.notifications),
                ),
              )
            ]),
            const SizedBox(
              width: 20,
            ),
            GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ChatRoomScreen()));
                },
                child: Icon(Icons.message_rounded)),
            const SizedBox(
              width: 20,
            )
          ],
        ),
        body: TabBarView(
          children: [..._pages],
        ),
        bottomNavigationBar: TabBar(
          padding: const EdgeInsets.only(top: 10),
          labelColor: Colors.amber.shade700,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.transparent,
          onTap: (index) {
            if (index == 4) {
              setState(() {
                isUserProfileTab = true;
              });
            } else {
              setState(() {
                isUserProfileTab = false;
              });
            }
          },
          tabs: [
            const Tab(
              icon: Icon(
                Icons.home,
                size: 40,
              ),
            ),
            const Tab(
              icon: Icon(Icons.search, size: 40),
            ),
            const Tab(
              icon: Icon(Icons.add, size: 40),
            ),
            const Tab(
              icon: Icon(Icons.settings, size: 40),
            ),
            Tab(
              child: Container(
                decoration: isUserProfileTab
                    ? BoxDecoration(
                        border:
                            Border.all(width: 4, color: Colors.amber.shade700),
                        shape: BoxShape.circle)
                    : null,
                child: CircleAvatar(
                  backgroundImage:
                      NetworkImage(userAuthViewModel.currentUser!.image),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
