import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/models/chat_model.dart';
import 'package:recipe_flutter_app/models/user_model.dart';
import 'package:recipe_flutter_app/schemas/chat_message.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';
import 'package:recipe_flutter_app/views/chat_view.dart';
import 'package:recipe_flutter_app/views/recipe_detail_view.dart';
import 'package:recipe_flutter_app/views/user_detail_view.dart';
import 'package:recipe_flutter_app/models/local_notification_model.dart';

//this handler function is a top-level function required for handling background messages or after app is terminated
// You can perform any task like saving data, processing notifications, etc.
//the backgroundhandler cannot be used for navigation because it runs in a different isolate.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (message.data.containsKey("type")) {
    if (message.data["type"] == "chatMessage") {
      final chatRoomId = message.data["chatRoomId"];
      final chatMessageId = message.data["chatMessageId"];
      final chatModel = ChatModel();

      await chatModel.updateChatMessageToDelivered(
          chatRoomId, chatMessageId, MessageStatus.delivered);
    }
  }
}

class PushNotificationModel {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final userViewModel = Provider.of<UserAuthViewModel>(
      navigatorKey.currentState!.context,
      listen: false);

  //for iOS, we have to request permission
  void requestPermission() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
    }
  }

  handleMessage(RemoteMessage? message) async {
    if (message != null) {
      await userViewModel.getUserById(userViewModel.currentUser!.id);

      if (message.data["type"] == "follow") {
        final userId = message.data["userId"];

        Navigator.of(navigatorKey.currentState!.context).push(MaterialPageRoute(
            builder: (context) => UserDetailScreen(userId: userId!)));
      }

      if (message.data["type"] == "comment" || message.data["type"] == "like") {
        final recipeId = message.data["recipeId"];
        Navigator.of(navigatorKey.currentState!.context).push(MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(
                  recipeId: recipeId,
                )));
      }
      if (message.data["type"] == "chatMessage") {
        final chatRoomId = message.data["chatRoomId"];
        Navigator.of(navigatorKey.currentState!.context).push(MaterialPageRoute(
            builder: (context) => ChatScreen(chatRoomId: chatRoomId)));
      }
    }
  }
  // Define the background message handler

  void setupFirebaseMessaging() {
    final userAuthModel = UserModel();
    //this is called when app is in foreground state.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        await userViewModel.getUserById(userViewModel.currentUser!.id);

        LocalNotificationModel().showNotification(
            id: 0,
            title: message.notification!.title!,
            body: message.notification!.body!,
            payload: jsonEncode(message.data));
      }
    });

    //this is called when you click on notification when app is in background.
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // //this is when you click notification when app is terminated or not running.
    firebaseMessaging.getInitialMessage().then(handleMessage);

    firebaseMessaging.getToken().then((String? token) async {
      print("FCM Token of this device is: $token");
      // Send the token to your server to register the device
      if (token != null) {
        await userAuthModel.saveFcmToken(token);
      }
    });
    firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print("onTokenRefresh is called");
      print(" New FCM Token after onTokenRefresh is: $newToken");

      // Send the new token to your server
      await userAuthModel.saveFcmToken(newToken);
    });
  }

  init() {
    requestPermission();
    setupFirebaseMessaging();
  }
}
