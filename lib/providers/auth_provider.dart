import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/models/user.dart';
import 'package:recipe_flutter_app/screens/login_screen.dart';
import 'package:recipe_flutter_app/services/api_services.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await ApiService().logout();
    _user = null;
    notifyListeners();

    Navigator.of(navigatorKey.currentState!.context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  Future<void> login(String email, String password) async {
    final user = await ApiService().login(email, password);
    _user = user;

    notifyListeners();
  }

  Future<void> signup(
      String email, String password, XFile image, String username) async {
    final user = await ApiService().signUp(email, password, username, image);

    _user = user;
    notifyListeners();
  }

  Future<User?> getUserById(String userId) async {
    _user = await ApiService().getUserById(userId);
    notifyListeners();
    return _user;
  }
}
