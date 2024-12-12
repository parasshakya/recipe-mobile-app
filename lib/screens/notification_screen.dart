import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/models/notification.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({required this.notifications, super.key});

  final List<UserNotification> notifications;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications"),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Text("No notifications to show"),
            )
          : Column(
              children: [
                ...notifications.map((e) => Card(
                      child: ListTile(
                        title: Text(e.message),
                        trailing: e.type == NotificationType.follow
                            ? Icon(Icons.follow_the_signs)
                            : Icon(Icons.notifications),
                      ),
                    ))
              ],
            ),
    );
  }
}
