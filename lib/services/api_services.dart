import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/config/config.dart';
import 'package:recipe_flutter_app/models/chat_message.dart';
import 'package:recipe_flutter_app/models/chat_room.dart';
import 'package:recipe_flutter_app/models/notification.dart';
import 'package:recipe_flutter_app/screens/login_screen.dart';
import 'package:recipe_flutter_app/utils.dart';
import 'package:recipe_flutter_app/interceptors/app_interceptor.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/models/recipe.dart';
import "package:http/http.dart" as http;
import 'package:recipe_flutter_app/models/user.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';

class ApiService {
  late final Dio dio;
  final authProvider = Provider.of<AuthProvider>(
      navigatorKey.currentState!.context,
      listen: false);

  ApiService() {
    dio = Dio(BaseOptions(
      baseUrl: Config.baseUrl,
      connectTimeout: const Duration(seconds: 10), // 10 seconds
      receiveTimeout: const Duration(seconds: 15), // 15 seconds
    ));
    dio.interceptors.add(AppInterceptor(dio: dio));
  }

  final _secureStorage = const FlutterSecureStorage();

  Future<void> createRecipe(Recipe recipe) async {
    try {
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

  Future<List<ChatRoom>> getMyChatRooms() async {
    try {
      final response = await dio.get("/chatRooms");
      final data = response.data;
      print(data);
      final chatRooms = data['chatRooms'] as List;

      return chatRooms.map((e) => ChatRoom.fromJson(e)).toList();
    } catch (e) {
      print("Error while fetching chatRooms");
      throw Exception("Failed to load chatRooms");
    }
  }

  Future<Response> getMessagesFromChatRoomId(String chatroomId,
      {DateTime? beforeTimestamp, int limit = 20}) async {
    try {
      final response = await dio.get("/chatMessages", queryParameters: {
        "limit": limit,
        "chatRoomId": chatroomId,
        if (beforeTimestamp != null) "before": beforeTimestamp.toIso8601String()
      });
      return response;
    } catch (e) {
      print("Error while fetching messages");
      throw Exception("Error while fetching messages: ${e}");
    }
  }

  Future<void> clearUserData() async {
    try {
      _secureStorage.delete(key: "userData");
    } catch (e) {
      throw Exception("Failed to clear user data from local storage: $e");
    }
  }

  Future<ChatRoom> getChatRoom(String chatRoomId) async {
    try {
      final response = await dio.get("/chatRooms/$chatRoomId");

      final data = response.data;
      final chatRoom = data["chatRoom"];
      return ChatRoom.fromJson(chatRoom);
    } catch (e) {
      print("Error fetching chatroom");
      throw Exception("Error fetching chatroom data");
    }
  }

  Future<void> updateChatMessageToDelivered(
      String chatRoomId, String chatMessageId, MessageStatus status) async {
    try {
      final response = await dio.put("/chatMessages", data: {
        "chatRoomId": chatRoomId,
        "chatMessageId": chatMessageId,
        "status": status.name
      });
    } catch (e) {
      print("Error while updating message");
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

  Future<Recipe> postLike(String recipeId) async {
    try {
      final response = await dio.post("/recipes/like/$recipeId");
      if (response.statusCode != 200) {
        throw Exception("Failed to post like");
      }
      final data = response.data;
      final recipe = Recipe.fromJson(data["data"]);
      return recipe;
    } catch (e) {
      print("Error posting like: $e");
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final dio = Dio();
      final refreshToken = await _secureStorage.read(key: "refreshToken");
      final fcmToken = await _secureStorage.read(key: "fcmToken");
      final response = await dio.post("${Config.baseUrl}/auth/logout", data: {
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

  Future<List<UserNotification>> fetchNotifications() async {
    try {
      final response =
          await dio.get("/notifications/${authProvider.currentUser!.id}");

      if (response.statusCode != 200) throw ("Error fetching notifications");

      print(response.data);
      final data = response.data["data"] as List;
      return data.map((e) => UserNotification.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching notifications $e");
      rethrow;
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

  Future<List<Recipe>> getRecipesByUser({required String userId}) async {
    try {
      final response = await dio.get("/recipes/user/$userId");

      if (response.statusCode == 200) {
        final data = response.data;
        final recipes = data["data"] as List;
        return recipes.map((e) => Recipe.fromJson(e)).toList();
      } else {
        throw Exception();
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

  Future<void> saveFcmToken(String fcmToken) async {
    try {
      final response =
          await dio.post("/users/save-fcm-token", data: {"fcmToken": fcmToken});
      await _secureStorage.write(key: "fcmToken", value: fcmToken);
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

  Future<Recipe> postComment(String recipeId, String text) async {
    try {
      final response =
          await dio.post("/recipes/comment/$recipeId", data: {"text": text});
      print("RESPONSE STATUS: ${response.statusCode}");
      if (response.statusCode != 200) {
        throw Exception("Error while commenting");
      }
      final data = response.data;
      return Recipe.fromJson(data["data"]);
    } catch (e) {
      print("Error while commenting");
      rethrow;
    }
  }

  Future<User> unfollowUser(String userId) async {
    try {
      final response = await dio.post("/users/unfollow/$userId");
      if (response.statusCode == 200) {
        final data = response.data;
        final currentUser = data["data"];
        return User.fromJson(currentUser);
      } else {
        throw Exception();
      }
    } catch (e) {
      print("Error unfollowing user: $e");
      rethrow;
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

  Future<User> getUserById(String userId) async {
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

  Future<List<ChatMessage>> getMessages(
      String senderId, String receiverId) async {
    try {
      final response = await dio.get("/chatMessages",
          queryParameters: {"senderId": senderId, "recipientId": receiverId});

      if (response.statusCode != 200) {
        throw Exception("error getting messages");
      }

      final data = response.data;
      final messages = data["messages"] as List;
      return messages.map((e) => ChatMessage.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
