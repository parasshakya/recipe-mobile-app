import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:recipe_flutter_app/config/config.dart';
import 'package:recipe_flutter_app/views/login_view.dart';
import 'package:recipe_flutter_app/utils.dart';
import 'package:recipe_flutter_app/interceptors/app_interceptor.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/schemas/user.dart';

class AuthModel {
  late final Dio dio;

  AuthModel() {
    dio = Dio(BaseOptions(
      baseUrl: Config.localBaseUrl,
      connectTimeout: const Duration(seconds: 10), // 10 seconds
      receiveTimeout: const Duration(seconds: 15), // 15 seconds
    ));
    dio.interceptors.add(AppInterceptor(dio: dio));
  }

  final _secureStorage = const FlutterSecureStorage();

  Future<User> createUserWithGoogle(String idToken) async {
    try {
      final response =
          await dio.post("/auth/google", data: {"idToken": idToken});
      if (response.statusCode == 200) {
        print("Google user created successfully");
        showSnackbar("Sign-in successful", navigatorKey.currentState!.context);
      }
      final data = response.data;
      final accessToken = data["data"]["accessToken"];
      final userData = data["data"]["userData"];
      final refreshToken = data["data"]["refreshToken"];

      final userDataString = jsonEncode(userData);

      print(userDataString);

      await _secureStorage.write(key: "accessToken", value: accessToken);
      await _secureStorage.write(key: "refreshToken", value: refreshToken);
      await _secureStorage.write(key: "userData", value: userDataString);

      return User.fromJson(userData);
    } catch (e) {
      print("Error while creating user with google");
      showSnackbar("Error while signing in. Please try again later.",
          navigatorKey.currentState!.context);
    }
    throw Exception("Failed to create user with google sign-in");
  }

  Future<void> clearUserData() async {
    try {
      _secureStorage.delete(key: "userData");
    } catch (e) {
      throw Exception("Failed to clear user data from local storage: $e");
    }
  }

  Future<void> clearTokens() async {
    try {
      _secureStorage.delete(key: "accessToken");
      _secureStorage.delete(key: "refreshToken");
      _secureStorage.delete(key: "fcmToken");
    } catch (e) {
      throw Exception("Failed to clear tokens from local storage: $e");
    }
  }

  Future<void> logout() async {
    try {
      final dio = Dio();
      final refreshToken = await _secureStorage.read(key: "refreshToken");
      final fcmToken = await _secureStorage.read(key: "fcmToken");
      final response =
          await dio.post("${Config.localBaseUrl}/auth/logout", data: {
        "refreshToken": refreshToken,
        "fcmToken": fcmToken,
      });
      if (response.statusCode == 200) {
        await clearUserData();
        await clearTokens();

        Navigator.of(navigatorKey.currentState!.context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token expired or invalid, clear stored tokens and navigate to login

        await clearUserData();
        await clearTokens();

        Navigator.of(navigatorKey.currentState!.context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen()));
      } else {
        print("Error during logout: ${e.message}");
        throw Exception("Error during logout");
      }
    }
  }

  Future<Response> fetchOTP(
    String email,
    String password,
    String username,
    XFile image,
  ) async {
    try {
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        "username": username,
        "email": email,
        "password": password,
        "image": await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        ),
      });

      final response = await dio.post(
        "/auth/signup",
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception(response.data["message"]);
      }

      return response;
    } catch (e) {
      print("Error during signup: $e");
      rethrow;
    }
  }

  Future<Response> resendOTP(String email) async {
    try {
      final response = await dio.post(
        "/otp/resendOTP",
        data: {"email": email},
      );

      return response;
    } catch (e) {
      print("Error during refetching otp: $e");

      throw Exception(
          "An error occurred during otp refetch. Please try again.");
    }
  }

  Future<User> verifyOTP(String email, String otp) async {
    try {
      final response = await dio.post(
        "/otp/verifyOTP",
        data: {"email": email, "otp": otp},
      );

      print("RESPONSE FROM VERIFYOTP IS: $response");

      if (response.statusCode != 200) {
        throw Exception("Error verifying user");
      }

      final data = response.data;
      final accessToken = data["data"]["accessToken"];
      final refreshToken = data["data"]["refreshToken"];
      final userData = data["data"]["userData"];

      final userDataString = jsonEncode(userData);

      await _secureStorage.write(key: "accessToken", value: accessToken);
      await _secureStorage.write(key: "refreshToken", value: refreshToken);
      await _secureStorage.write(key: "userData", value: userDataString);

      return User.fromJson(userData);
    } catch (e) {
      print("Error during signup: $e");

      throw Exception("An error occurred during signup. Please try again.");
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final loginData = {"email": email, "password": password};

      final response = await dio.post("/auth/login", data: loginData);
      if (response.statusCode != 200) {
        throw Exception("Failed to login. Please try again");
      }
      final data = response.data;
      final accessToken = data["data"]["accessToken"];
      final userData = data["data"]["userData"];
      final refreshToken = data["data"]["refreshToken"];

      final userDataString = jsonEncode(userData);

      print(userDataString);

      await _secureStorage.write(key: "accessToken", value: accessToken);
      await _secureStorage.write(key: "refreshToken", value: refreshToken);
      await _secureStorage.write(key: "userData", value: userDataString);

      return User.fromJson(userData);
    } catch (e) {
      throw Exception("Failed to login: $e ");
    }
  }
}
