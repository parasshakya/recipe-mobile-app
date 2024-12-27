import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/models/auth_model.dart';
import 'package:recipe_flutter_app/models/user_model.dart';
import 'package:recipe_flutter_app/schemas/user.dart';
import 'package:recipe_flutter_app/views/otp_verification_view.dart';

class UserAuthViewModel extends ChangeNotifier {
  final UserModel userModel;
  final AuthModel authModel;

  User? _currentUser;

  String? _otp;

  String? get otp => _otp;

  String? otpError;

  bool otpLoading = false;

  UserAuthViewModel({required this.userModel, required this.authModel});

  User? get currentUser => _currentUser;

  bool signUpError = false;
  bool signUpLoading = false;

  void setUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await authModel.logout();

    _currentUser = null;
  }

  Future<void> login(String email, String password) async {
    final user = await authModel.login(email, password);
    _currentUser = user;

    notifyListeners();
  }

  Future<void> verifyOTP(String email, String otp) async {
    final user = await authModel.verifyOTP(email, otp);

    _currentUser = user;
    notifyListeners();
  }

  Future<void> signInWithGoogle(String idToken) async {
    final user = await authModel.createUserWithGoogle(idToken);
    _currentUser = user;
    notifyListeners();
  }

  Future<bool> checkUser() async {
    FlutterSecureStorage secureStorage = const FlutterSecureStorage();

    final userData = await secureStorage.read(key: "userData");

    if (userData != null && userData.isNotEmpty) {
      final user = User.fromJson(jsonDecode(userData));
      await getUserById(user.id);
      return true;
    } else {
      return false;
    }
  }

  Future<void> resendOtp(String email) async {
    try {
      otpLoading = true;
      notifyListeners();
      await authModel.resendOTP(email);
    } catch (e) {
      print(e);
      otpError = "Something went wrong";
    } finally {
      otpLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(
      String email, String password, String username, XFile image) async {
    try {
      signUpError = false;
      signUpLoading = true;
      notifyListeners();
      await userModel.signUp(email, password, username, image);
    } catch (e) {
      print("Error while signing up: $e");
      signUpError = true;
    } finally {
      signUpLoading = false;
      notifyListeners();
    }
  }

  Future<User?> getUserById(String userId) async {
    _currentUser = await userModel.getUserById(userId);
    notifyListeners();
    return _currentUser;
  }

  Future followUser(String userId) async {
    _currentUser = await userModel.followUser(userId);
    notifyListeners();
  }

  Future unfollowUser(String userId) async {
    _currentUser = await userModel.unfollowUser(userId);
    notifyListeners();
  }
}
