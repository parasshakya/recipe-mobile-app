import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/models/recipe_model.dart';
import 'package:recipe_flutter_app/schemas/comment.dart';
import 'package:recipe_flutter_app/schemas/recipe.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';

class RecipeViewModel extends ChangeNotifier {
  RecipeModel recipeModel;

  RecipeViewModel({required this.recipeModel});

  List<Recipe> _recipes = [];

  List<Recipe> _searchRecipes = [];

  List<Recipe> get searchRecipes => _searchRecipes;

  bool searchRecipesLoading = false;

  String? searchRecipesError;

  List<Recipe> _myRecipes = [];

  Recipe? _recipeById;

  Recipe? get recipeById => _recipeById;

  List<Recipe> _recipesByUser = [];

  List<Recipe> get recipesByUser => _recipesByUser;

  bool recipesByUserLoading = false;

  String? recipesByUserError;

  bool _loading = false;

  get loading => _loading;

  bool _recipeByIdLoading = false;

  get recipeByIdLoading => _recipeByIdLoading;

  bool _myRecipesLoading = false;

  get myRecipesLoading => _myRecipesLoading;

  List<Comment> _commentsInARecipe = [];

  List<String>? _likesInARecipe;

  List<String>? get likesInARecipe => _likesInARecipe;

  bool likesInARecipeLoading = false;

  String? likesInARecipeError;

  List<Comment> get commentsInARecipe => _commentsInARecipe;

  bool commentsInARecipeLoading = false;

  String? commentsInARecipeError;

  bool hasMore = false;

  List<Recipe> get recipes => _recipes;

  int totalRecipeCount = 0;

  int currentPage = 1;

  clearRecipes() {
    _recipes = [];
    notifyListeners();
  }

  Future<void> loadAllRecipes({int limit = 10}) async {
    _loading = true;
    notifyListeners();

    final response =
        await recipeModel.getAllRecipes(limit: limit, page: currentPage);

    hasMore = response.data['data']['hasMore'];

    totalRecipeCount = response.data["data"]["totalRecipes"];

    final recipes = response.data['data']['recipes'] as List;

    print("TOTAL RECIPE $totalRecipeCount");
    print("HAS MORE $hasMore");

    _recipes.addAll(recipes.map((e) => Recipe.fromJson(e)));
    _loading = false;

    notifyListeners();
  }

  Future<void> loadCommentsInARecipe(String recipeId) async {
    try {
      commentsInARecipeLoading = true;
      notifyListeners();
      _commentsInARecipe = await recipeModel.getCommentsInARecipe(recipeId);
    } catch (e) {
      print(e);
      commentsInARecipeError = "Something went wrong";
    } finally {
      commentsInARecipeLoading = false;
      notifyListeners();
    }
  }

  Future<void> getById(String recipeId) async {
    _recipeByIdLoading = true;
    notifyListeners();
    _recipeById = await recipeModel.getRecipeById(recipeId);

    _recipeByIdLoading = false;
    notifyListeners();
  }

  fetchMyRecipes() async {
    try {
      _myRecipesLoading = true;
      notifyListeners();
      final currentUser = Provider.of<UserAuthViewModel>(
              navigatorKey.currentState!.context,
              listen: false)
          .currentUser;
      _myRecipes = await recipeModel.getRecipesByUser(userId: currentUser!.id);
      _myRecipesLoading = false;
      notifyListeners();
    } catch (e) {}
  }

  getRecipesByUser(String userId) async {
    try {
      recipesByUserLoading = true;
      notifyListeners();
      _recipesByUser = await recipeModel.getRecipesByUser(userId: userId);
    } catch (e) {
      recipesByUserError = "Something went wrong";
    } finally {
      recipesByUserLoading = false;
    }
    notifyListeners();
  }

  createRecipe(Recipe recipe) async {
    try {
      await recipeModel.createRecipe(recipe);
    } catch (e) {
      print(e);
    }
  }

  postComment(String recipeId, String text) async {
    try {
      commentsInARecipeLoading = true;
      notifyListeners();
      final recipe = await recipeModel.postComment(recipeId, text);
      _commentsInARecipe = await recipeModel.getCommentsInARecipe(recipe.id);
    } catch (e) {
      commentsInARecipeError = "Something went wrong";
    } finally {
      commentsInARecipeLoading = false;
      notifyListeners();
    }
  }

  postLikes(String recipeId) async {
    try {
      likesInARecipeLoading = true;
      notifyListeners();
      _recipeById = await recipeModel.postLike(recipeId);
      _likesInARecipe = recipeById!.likeIds!;
    } catch (e) {
      print(e);
      likesInARecipeError = "Something went wrong";
    } finally {
      likesInARecipeLoading = false;
      notifyListeners();
    }
  }

  searchForRecipes(String query) async {
    try {
      if (query.isEmpty) {
        _searchRecipes = [];
        notifyListeners();
        return;
      }

      searchRecipesLoading = true;
      notifyListeners();

      _searchRecipes = await recipeModel.searchForRecipes(query);
    } catch (e) {
      searchRecipesError = "Something went wrong";
    } finally {
      searchRecipesLoading = false;
      notifyListeners();
    }
  }
}
