import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/models/recipe.dart';
import 'package:recipe_flutter_app/services/api_services.dart';

class RecipeProvider extends ChangeNotifier {
  List<Recipe> _recipes = [];

  bool hasMore = false;

  List<Recipe> get recipes => _recipes;

  int totalRecipeCount = 0;

  int currentPage = 1;

  setRecipes(List<Recipe> recipes) {
    _recipes = recipes;
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

  getRecipesByUser() async {}
}
