import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/config/config.dart';
import 'package:recipe_flutter_app/constants.dart';
import 'package:recipe_flutter_app/interceptors/auth_interceptor.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/models/recipe.dart';
import "package:http/http.dart" as http;
import 'package:recipe_flutter_app/models/user.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';

class ApiService {
  late final Dio dio;

  ApiService() {
    dio = Dio(BaseOptions(
      baseUrl: Config.baseUrl,
      connectTimeout: const Duration(seconds: 10), // 10 seconds
      receiveTimeout: const Duration(seconds: 15), // 15 seconds
    ));
    dio.interceptors.add(AuthInterceptor(dio: dio));
  }

  final _secureStorage = const FlutterSecureStorage();

  Future<void> createRecipe(Recipe recipe) async {
    try {
      // http.Response response = await http.post(Uri.parse("$baseUrl/recipes"),
      //     headers: {"Content-Type": "application/json"},
      //     body: recipeJsonString);

      final response = await dio.post("/recipes", data: recipe.toJson());

      if (response.statusCode == 201) {
        print("Recipe Created");
      } else {
        print("Recipe failed to create");
      }
    } catch (e) {
      throw Exception(e);
    }
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
    } catch (e) {
      throw Exception("Failed to clear tokens from local storage: $e");
    }
  }

  Future<void> logout() async {
    try {
      final refreshToken = await _secureStorage.read(key: "refreshToken");
      final response = await dio.post("/auth/logout",
          options: Options(headers: {"Refresh-Token": refreshToken}));
      if (response.statusCode == 200) {
        await clearUserData();
        await clearTokens();
      }
    } catch (e) {
      throw Exception("Failed to logout: $e");
    }
  }

  Future<Response> getAllRecipes(
      {required int limit, required int page}) async {
    try {
      final response = await dio
          .get("/recipes", queryParameters: {"page": page, "limit": limit});

      if (response.statusCode == 200) {
        return response;
      } else {
        throw Exception("Error while fetching recipes");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Recipe> getRecipeById(String id) async {
    try {
      final response = await dio.get("/recipes/$id");

      if (response.statusCode == 200) {
        final data = response.data;

        final recipe = data['data'];

        return Recipe.fromJson(recipe);
      } else {
        throw Exception(
            "Error while fetching recipe: Status Code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error while fetching recipe $e");
      throw Exception(e);
    }
  }

  Future<User> signUp(
    String email,
    String password,
    String username,
    XFile image,
  ) async {
    try {
      // final userJsonString = jsonEncode(userInfo.toJson());

      // http.Response response = await http.post(
      //     Uri.parse("$baseUrl/auth/signup"),
      //     headers: {"Content-Type": "application/json"},
      //     body: userJsonString);

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

      if (response.statusCode != 201) {
        throw Exception("Failed to Sign up. Please try again.");
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

  Future<void> saveFcmToken(String fcmToken, String userId) async {
    try {
      final response = await dio.post("/users/save-fcm-token",
          data: {"fcmToken": fcmToken, "userId": userId});
    } catch (e) {
      print("Error saving fcm token");
      throw Exception("Error saving Fcm Token: $e");
    }
  }

  Future<User?> followUser(String userId) async {
    try {
      final response = await dio.post("/users/follow/$userId");
      if (response.statusCode != 200) {
        throw Exception("Error while following user");
      }
      final data = response.data["data"];
      print("MESSAGE: ${response.data["message"]}");

      final user = User.fromJson(data);
      return user;
    } catch (e) {
      print("Error while following user: $e");
      throw Exception("Error while following user");
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      final response = await dio.post("/users/unfollow/$userId");
    } catch (e) {
      print("Error unfollowing user: $e");
      throw Exception("Error unfollowing user");
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

      await _secureStorage.write(key: "accessToken", value: accessToken);
      await _secureStorage.write(key: "refreshToken", value: refreshToken);
      await _secureStorage.write(key: "userData", value: userDataString);

      return User.fromJson(userData);
    } catch (e) {
      throw Exception("Failed to login: $e ");
    }
  }

  Future<User?> getUserById(String userId) async {
    try {
      final response = await dio.get("/users/$userId");
      if (response.statusCode == 200) {
        final data = response.data["data"];
        final user = User.fromJson(data);
        return user;
      } else {
        throw Exception("Failed to get user");
      }
    } catch (e) {
      print("Error while fetching user: $e");
      throw Exception("Error while fetching user");
    }
  }
}
