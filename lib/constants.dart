import 'package:flutter/material.dart';

showSnackbar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String baseUrl =
    "http://10.0.2.2:3002"; // Host machine IP address for android emulator

//Host machine IP address for iOS simulator is : 127.0.0.1:3002
