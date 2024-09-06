import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/firebase_options.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/providers/recipe_provider.dart';
import 'package:recipe_flutter_app/screens/recipe_detail_screen.dart';
import 'package:recipe_flutter_app/services/api_services.dart';
import 'package:recipe_flutter_app/services/local_notification_service.dart';

//this handler function is a top-level function required for handling background messages or after app is terminated
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('Handling a background message: ${message.messageId}');
  // You can perform any task like saving data, processing notifications, etc.
  print('Message data: ${message.data}');
  if (message.notification != null) {
    print('Message also contained a notification: ${message.notification}');
  }
}

class PushNotificationService {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

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

  // Define the background message handler

  void setupFirebaseMessaging() {
    final context = navigatorKey.currentState!.context;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user!;
    // Register the background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    //this is when you click notification when app is terminated or not running.
    firebaseMessaging.getInitialMessage().then((message) async {
      if (message != null) {
        final screen = message.data["screen"];
        final recipeId = message.data["recipeId"];

        final context = navigatorKey.currentState!.context;

        final recipe = await Provider.of<RecipeProvider>(context, listen: false)
            .getById(recipeId);

        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipe: recipe)));
      }
    });

    //this is called when app is in foreground state.
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Received a message while in the foreground!');
      print('Message data: ${message.data}');
      print("Message Notification: ${message.notification}");

      if (message.notification != null) {
        LocalNotificationService().showNotification(
            id: 0,
            title: message.notification!.title!,
            body: message.notification!.body!,
            payload: jsonEncode(message.data));
      }
    });

    //this is called when app is in background.
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      print('A new onMessageOpenedApp event was published!');
      // Handle when the app is opened via a notification tap

      final screen = message.data["screen"];
      final recipeId = message.data["recipeId"];

      final context = navigatorKey.currentState!.context;

      final recipe = await Provider.of<RecipeProvider>(context, listen: false)
          .getById(recipeId);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => RecipeDetailScreen(recipe: recipe)));
    });

    FirebaseMessaging.instance.getToken().then((String? token) async {
      print("FCM Token: $token");
      // Send the token to your server to register the device
      if (token != null) {
        await ApiService().saveFcmToken(token, user.id);
      }
    });
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print(" New FCM Token: $newToken");

      // Send the new token to your server
      await ApiService().saveFcmToken(newToken, user.id);
    });
  }

  init() {
    requestPermission();
    setupFirebaseMessaging();
  }
}
