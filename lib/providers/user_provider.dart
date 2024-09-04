import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/models/user.dart';
import 'package:recipe_flutter_app/services/api_services.dart';

class UserProvider extends ChangeNotifier {
  User? _user;

  setUser(User user) {
    _user = user;
    notifyListeners();
  }

  User? get user => _user;

  Future<User?> followUser(String userId) async {
    _user = await ApiService().followUser(userId);

    notifyListeners();
    return _user;
  }
}
