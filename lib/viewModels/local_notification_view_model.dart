import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/models/local_notification_model.dart';

class LocalNotificationViewModel extends ChangeNotifier {
  final LocalNotificationModel localNotificationModel;

  LocalNotificationViewModel({required this.localNotificationModel});

  Future<void> init() async {
    localNotificationModel.init();
  }
}
