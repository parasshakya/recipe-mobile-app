import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/views/recipe_detail_view.dart';
import 'package:recipe_flutter_app/views/user_detail_view.dart';

class LocalNotificationModel {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveLocalNotification);
  }

  Future<void> showNotification(
      {required int id,
      required String title,
      required String body,
      String? payload}) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _flutterLocalNotificationsPlugin
        .show(id, title, body, notificationDetails, payload: payload);
  }

  void onDidReceiveLocalNotification(NotificationResponse? response) async {
    final payload = jsonDecode(response!.payload!);

    final context = navigatorKey.currentContext;

    if (payload["type"] == "follow") {
      final userId = payload["userId"];
      Navigator.of(context!).push(MaterialPageRoute(
          builder: (context) => UserDetailScreen(userId: userId!)));
    }
    if (payload["type"] == "comment" || payload["type"] == "like") {
      final recipeId = payload["recipeId"];
      Navigator.of(context!).push(MaterialPageRoute(
          builder: (context) => RecipeDetailScreen(
                recipeId: recipeId,
              )));
    }
  }
}
