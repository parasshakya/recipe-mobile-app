import 'package:flutter/material.dart';

showSnackbar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

String baseUrl = "http://192.168.101.8:3002";
