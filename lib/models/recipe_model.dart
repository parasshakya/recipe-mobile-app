import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:recipe_flutter_app/config/config.dart';
import 'package:recipe_flutter_app/schemas/comment.dart';
import 'package:recipe_flutter_app/interceptors/app_interceptor.dart';
import 'package:recipe_flutter_app/schemas/recipe.dart';

class RecipeModel {
  late final Dio dio;

  RecipeModel() {
    dio = Dio(BaseOptions(
      baseUrl: Config.localBaseUrl,
      connectTimeout: const Duration(seconds: 10), // 10 seconds
      receiveTimeout: const Duration(seconds: 15), // 15 seconds
    ));
    dio.interceptors.add(AppInterceptor(dio: dio));
  }

  final _secureStorage = const FlutterSecureStorage();

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

  Future<List<Comment>> getCommentsInARecipe(String recipeId) async {
    final response = await dio.get("/recipes/${recipeId}/comments");
    final comments = response.data["data"] as List;
    return comments.map((e) => Comment.fromJson(e)).toList();
  }

  Future<Recipe> postComment(String recipeId, String text) async {
    try {
      final response = await dio.post("/recipes/comments",
          data: {"recipeId": recipeId, "text": text});
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

      final data = response.data;
      final recipes = data["data"] as List;
      return recipes.map((e) => Recipe.fromJson(e)).toList();
    } catch (e) {
      print("Error while fetching recipes");
      throw Exception("Error while fetching recipes");
    }
  }

  Future<void> createRecipe(Recipe recipe) async {
    String fileName = recipe.image.split('/').last;
    FormData formdata = FormData.fromMap({
      ...recipe.toJson(),
      "image": await MultipartFile.fromFile(recipe.image, filename: fileName)
    });
    await dio.post("/recipes",
        data: formdata,
        options: Options(headers: {"Content-Type": "multipart/form-data"}));
  }

  Future<List<Recipe>> searchForRecipes(String query) async {
    final response =
        await dio.get("/recipes/search", queryParameters: {"query": query});

    if (response.statusCode != 200) {
      throw Exception("Something went wrong");
    }

    final recipes = response.data["data"] as List;
    return recipes.map((e) => Recipe.fromJson(e)).toList();
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
}
