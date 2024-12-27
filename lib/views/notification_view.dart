import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/schemas/notification.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({required this.notifications, super.key});

  final List<UserNotification> notifications;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Text("No notifications to show"),
            )
          : Column(
              children: [
                ...notifications.map((e) => Card(
                      child: ListTile(
                        title: Text(e.message),
                        trailing: e.type == NotificationType.follow
                            ? const Icon(Icons.follow_the_signs)
                            : const Icon(Icons.notifications),
                      ),
                    ))
              ],
            ),
    );
  }
}
