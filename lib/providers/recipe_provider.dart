import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/models/recipe.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/services/api_services.dart';

class RecipeProvider extends ChangeNotifier {
  List<Recipe> _recipes = [];

  List<Recipe> _myRecipes = [];

  bool hasMore = false;

  List<Recipe> get recipes => _recipes;

  int totalRecipeCount = 0;

  int currentPage = 1;

  setRecipes(List<Recipe> recipes) {
    _recipes = recipes;
    notifyListeners();
  }

  clearRecipes() {
    _recipes = [];
    notifyListeners();
  }

  Future<void> fetchAllRecipes({int limit = 10}) async {
    final response =
        await ApiService().getAllRecipes(limit: limit, page: currentPage);

    hasMore = response.data['data']['hasMore'];

    totalRecipeCount = response.data["data"]["totalRecipes"];

    final recipes = response.data['data']['recipes'] as List;

    print("TOTAL RECIPE $totalRecipeCount");
    print("HAS MORE $hasMore");

    _recipes.addAll(recipes.map((e) => Recipe.fromJson(e)));

    notifyListeners();
  }

  Future<Recipe> getById(String recipeId) async {
    final recipe = await ApiService().getRecipeById(recipeId);
    return recipe;
  }

  fetchMyRecipes() async {
    final currentUser = Provider.of<AuthProvider>(
            navigatorKey.currentState!.context,
            listen: false)
        .currentUser;
    _myRecipes = await ApiService().getRecipesByUser(userId: currentUser!.id);
    notifyListeners();
  }
}
