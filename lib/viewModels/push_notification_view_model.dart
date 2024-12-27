import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/models/push_notification_model.dart';

class PushNotificationViewModel extends ChangeNotifier {
  final PushNotificationModel pushNotificationModel;

  PushNotificationViewModel({required this.pushNotificationModel});

  Future<void> init() async {
    pushNotificationModel.init();
  }
}
