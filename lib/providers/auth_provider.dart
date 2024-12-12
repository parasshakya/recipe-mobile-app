import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/models/user.dart';
import 'package:recipe_flutter_app/providers/recipe_provider.dart';
import 'package:recipe_flutter_app/screens/login_screen.dart';
import 'package:recipe_flutter_app/services/api_services.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;

  void setUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await ApiService().logout();

    _currentUser = null;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    final user = await ApiService().login(email, password);
    _currentUser = user;

    notifyListeners();
  }

  Future<void> signup(String email, String otp) async {
    final user = await ApiService().verifyOTP(email, otp);

    _currentUser = user;
    notifyListeners();
  }

  Future<void> signInWithGoogle(String idToken) async {
    final user = await ApiService().createUserWithGoogle(idToken);
    _currentUser = user;
    notifyListeners();
  }

  Future<User?> getUserById(String userId) async {
    _currentUser = await ApiService().getUserById(userId);
    notifyListeners();
    return _currentUser;
  }

  Future followUser(String userId) async {
    _currentUser = await ApiService().followUser(userId);
    notifyListeners();
  }

  Future unfollowUser(String userId) async {
    _currentUser = await ApiService().unfollowUser(userId);
    notifyListeners();
  }
}
