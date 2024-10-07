import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/models/user.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/providers/recipe_provider.dart';
import 'package:recipe_flutter_app/screens/home_screen.dart';
import 'package:recipe_flutter_app/screens/login_screen.dart';
import 'package:recipe_flutter_app/screens/recipe_detail_screen.dart';
import 'package:recipe_flutter_app/services/api_services.dart';
import 'package:recipe_flutter_app/services/push_notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  Widget? screen;
  bool loading = true;
  late AuthProvider authProvider;

  Future<bool> checkUser() async {
    final userData = await secureStorage.read(key: "userData");
    authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (userData != null && userData.isNotEmpty) {
      final user = User.fromJson(jsonDecode(userData));
      await authProvider.getUserById(user.id);
      return true;
    } else {
      return false;
    }
  }

  buildScreen() async {
    final isUser = await checkUser();
    if (isUser) {
      screen = HomeScreen();
    } else {
      screen = LoginScreen();
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    buildScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return screen!;
    }
  }
}
