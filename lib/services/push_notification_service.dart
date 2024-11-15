import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/firebase_options.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/models/user.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/providers/recipe_provider.dart';
import 'package:recipe_flutter_app/screens/chat_screen.dart';
import 'package:recipe_flutter_app/screens/recipe_detail_screen.dart';
import 'package:recipe_flutter_app/screens/user_detail_screen.dart';
import 'package:recipe_flutter_app/services/api_services.dart';
import 'package:recipe_flutter_app/services/local_notification_service.dart';

//this handler function is a top-level function required for handling background messages or after app is terminated
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // You can perform any task like saving data, processing notifications, etc.
}

class PushNotificationService {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final authProvider = Provider.of<AuthProvider>(
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
      await authProvider.getUserById(authProvider.currentUser!.id);

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
    // Register the background message handler for data processing and updating local storage
    //the backgroundhandler cannot be used for navigation because it runs in a different isolate.

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    //this is called when app is in foreground state.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        await authProvider.getUserById(authProvider.currentUser!.id);

        LocalNotificationService().showNotification(
            id: 0,
            title: message.notification!.title!,
            body: message.notification!.body!,
            payload: jsonEncode(message.data));
      }
    });

    //this is called when app is in background.
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);

    // //this is when you click notification when app is terminated or not running.
    firebaseMessaging.getInitialMessage().then(handleMessage);

    firebaseMessaging.getToken().then((String? token) async {
      print("getToken is called");
      print("FCM Token: $token");
      // Send the token to your server to register the device
      if (token != null) {
        await ApiService().saveFcmToken(token);
      }
    });
    firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print("onTokenRefresh is called");
      print(" New FCM Token: $newToken");

      // Send the new token to your server
      await ApiService().saveFcmToken(newToken);
    });
  }

  init() {
    requestPermission();
    setupFirebaseMessaging();
  }
}
