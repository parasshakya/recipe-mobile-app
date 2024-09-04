import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/screens/recipe_detail_screen.dart';
import 'package:recipe_flutter_app/services/api_services.dart';

class LocalNotificationService {
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
    print("THe payload is: ${response?.payload}");

    final payload = jsonDecode(response!.payload!);

    final recipeId = payload["recipeId"];

    print("Data after decode : ${payload}");
    // display a dialog with the notification details, tap ok to go to another page

    final recipe = await ApiService().getRecipeById(recipeId);
    Navigator.of(navigatorKey.currentState!.context).push(MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(recipe: recipe)));
  }
}
