import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/config/config.dart';
import 'package:recipe_flutter_app/schemas/category.dart';
import 'package:recipe_flutter_app/schemas/cuisine.dart';
import 'package:recipe_flutter_app/schemas/notification.dart';
import 'package:recipe_flutter_app/interceptors/app_interceptor.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/schemas/recipe.dart';
import 'package:recipe_flutter_app/schemas/user.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';

class UserModel {
  late final Dio dio;

  UserModel() {
    dio = Dio(BaseOptions(
      baseUrl: Config.localBaseUrl,
      connectTimeout: const Duration(seconds: 10), // 10 seconds
      receiveTimeout: const Duration(seconds: 15), // 15 seconds
    ));
    dio.interceptors.add(AppInterceptor(dio: dio));
  }

  final _secureStorage = const FlutterSecureStorage();

  Future<List<UserNotification>> fetchNotifications() async {
    final response = await dio.get("/notifications");

    if (response.statusCode != 200) throw ("Error fetching notifications");

    print(response.data);
    final data = response.data["data"] as List;
    return data.map((e) => UserNotification.fromJson(e)).toList();
  }

  Future<Response> signUp(
    String email,
    String password,
    String username,
    XFile image,
  ) async {
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
  }

  Future<List<Recipe>> getRecipesByUser({required String userId}) async {
    try {
      final response = await dio.get("/recipes/user/$userId");

      final data = response.data;
      final recipes = data["data"] as List;
      return recipes.map((e) => Recipe.fromJson(e)).toList();
    } catch (e) {
      print("Error while fetching recipes");
      throw Exception("Error while fetching recipes");
    }
  }

  Future<List<Recipe>> searchForRecipes(String query) async {
    try {
      final response =
          await dio.get("/recipes/search", queryParameters: {"query": query});

      final recipes = response.data["data"] as List;
      return recipes.map((e) => Recipe.fromJson(e)).toList();
    } catch (e) {
      print("error while searching recipes");
      throw Exception("Error while searching for recipes");
    }
  }

  Future<List<Cuisine>> fetchCuisines() async {
    final response = await dio.get("/cuisines");
    final cuisines = response.data['data'] as List;
    return cuisines.map((e) => Cuisine.fromJson(e)).toList();
  }

  Future<List<Category>> fetchCategories() async {
    final response = await dio.get("/categories");
    final categories = response.data['data'] as List;
    return categories.map((e) => Category.fromJson(e)).toList();
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

  Future<void> updateUser(String username, String bio, String imagePath) async {
    try {
      final currentUser =
          Provider.of<UserAuthViewModel>(navigatorKey.currentState!.context)
              .currentUser!;
      final fileName = imagePath.split('/').last;
      final formData = FormData.fromMap({
        "username": username,
        "bio": bio,
        "image": MultipartFile.fromFile(imagePath, filename: fileName)
      });
      final response =
          await dio.put("/users", queryParameters: {"userId": currentUser.id});
    } catch (e) {
      print("Error while updating user");
    }
  }

  Future<void> saveFcmToken(String fcmToken) async {
    final response =
        await dio.post("/users/save-fcm-token", data: {"fcmToken": fcmToken});
    await _secureStorage.write(key: "fcmToken", value: fcmToken);
    if (response.statusCode != 200) {
      throw Exception("Error saving Fcm Token");
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

  Future<User> getUserById(String userId) async {
    final response = await dio.get("/users/$userId");
    if (response.statusCode != 200) {
      throw Exception("Error while fetching User");
    }
    final data = response.data["data"];

    final user = User.fromJson(data);

    return user;
  }
}
