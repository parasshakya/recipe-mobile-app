import 'package:flutter/material.dart';

showSnackbar(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}


   
//Host machine IP address for iOS simulator is : 127.0.0.1:3002/api

