import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/screens/recipe_detail_screen.dart';
import 'package:recipe_flutter_app/screens/user_detail_screen.dart';
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
    final payload = jsonDecode(response!.payload!);

    final context = navigatorKey.currentContext;

    if (payload["screen"] == "/userDetail") {
      final user = await ApiService().getUserById(payload["userId"]);
      Navigator.of(context!).push(MaterialPageRoute(
          builder: (context) => UserDetailScreen(user: user!)));
    }
  }
}
