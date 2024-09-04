import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/models/recipe.dart';
import 'package:recipe_flutter_app/services/api_services.dart';

class RecipeProvider extends ChangeNotifier {
  List<Recipe> _recipes = [];

  List<Recipe> get recipes => _recipes;

  setRecipes(List<Recipe> recipes) {
    _recipes = recipes;
    notifyListeners();
  }

  Future<void> fetchAllRecipes() async {
    _recipes = await ApiService().getAllRecipes();
    notifyListeners();
  }

  Future<Recipe> getById(String recipeId) async {
    final recipe = await ApiService().getRecipeById(recipeId);
    return recipe;
  }
}
