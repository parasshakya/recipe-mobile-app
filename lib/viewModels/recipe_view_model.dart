import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/models/recipe_model.dart';
import 'package:recipe_flutter_app/schemas/comment.dart';
import 'package:recipe_flutter_app/schemas/recipe.dart';
import 'package:recipe_flutter_app/viewModels/category_view_model.dart';
import 'package:recipe_flutter_app/viewModels/cuisine_view_model.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';

class RecipeViewModel extends ChangeNotifier {
  RecipeModel recipeModel;

  RecipeViewModel({required this.recipeModel});

  List<Recipe> _recipes = [];

  bool recipesError = false;

  List<Recipe> _searchRecipes = [];

  List<Recipe> get searchRecipes => _searchRecipes;

  bool searchRecipesLoading = false;

  bool searchRecipesError = false;

  List<Recipe> _myRecipes = [];

  Recipe? _recipeById;

  Recipe? get recipeById => _recipeById;

  bool initRecipeError = false;

  bool recipeByIdError = false;

  bool recipeByIdLiked = false;

  List<Recipe> _recipesByUser = [];

  List<Recipe> get recipesByUser => _recipesByUser;

  bool recipesByUserLoading = false;

  bool recipesByUserError = false;

  bool _loading = false;

  get loading => _loading;

  bool _recipeByIdLoading = false;

  get recipeByIdLoading => _recipeByIdLoading;

  bool _myRecipesLoading = false;

  get myRecipesLoading => _myRecipesLoading;

  List<Comment> _commentsInARecipe = [];

  List<String> _likesInARecipe = [];

  List<String> get likesInARecipe => _likesInARecipe;

  bool likesInARecipeLoading = false;

  bool likesInARecipeError = false;

  bool isRecipeLiked = false;

  bool initRecipeLoading = true;

  List<Comment> get commentsInARecipe => _commentsInARecipe;

  bool commentsInARecipeLoading = false;

  bool commentsInARecipeError = false;

  bool hasMore = false;

  List<Recipe> get recipes => _recipes;

  int totalRecipeCount = 0;

  int currentPage = 1;

  Timer? timer;

  clearRecipes() {
    _recipes = [];
    notifyListeners();
  }

  Future<void> loadAllRecipes({int limit = 10}) async {
    try {
      if (loading) {
        return;
      }

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

      notifyListeners();
    } catch (e) {
      recipesError = true;
      notifyListeners();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> loadCommentsInARecipe(String recipeId) async {
    try {
      commentsInARecipeLoading = true;
      commentsInARecipeError = false;
      notifyListeners();

      _commentsInARecipe = await recipeModel.getCommentsInARecipe(recipeId);
    } catch (e) {
      commentsInARecipeError = true;
    } finally {
      commentsInARecipeLoading = false;
      notifyListeners();
    }
  }

  initializeRecipe(String recipeId, BuildContext context) async {
    initRecipeLoading = true;
    initRecipeError = false;
    notifyListeners();

    try {
      _recipeById = await recipeModel.getRecipeById(recipeId);
      getIsLikedForRecipe(context);

      final userAuthViewModel =
          Provider.of<UserAuthViewModel>(context, listen: false);

      final recipeUser =
          await userAuthViewModel.getUserById(recipeById!.userId);
      userAuthViewModel.setRecipeUser(recipeUser);

      await Provider.of<CuisineViewModel>(context, listen: false)
          .loadCuisine(recipeById!.cuisineId);
      await Provider.of<CategoryViewModel>(context, listen: false)
          .loadCategory(recipeById!.categoryId);
      await loadCommentsInARecipe(recipeId);
    } catch (e) {
      initRecipeError = true;
    } finally {
      initRecipeLoading = false;
      notifyListeners();
    }
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
      recipesByUserError = false;
      notifyListeners();
      _recipesByUser = await recipeModel.getRecipesByUser(userId: userId);
    } catch (e) {
      recipesByUserError = true;
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
      commentsInARecipeError = false;
      notifyListeners();

      final recipe = await recipeModel.postComment(recipeId, text);
      _commentsInARecipe = await recipeModel.getCommentsInARecipe(recipe.id);
    } catch (e) {
      commentsInARecipeError = true;
    } finally {
      commentsInARecipeLoading = false;
      notifyListeners();
    }
  }

  postLikes(String recipeId) async {
    toggleLikeInRecipeById(); // quickly show the user the like state change

    try {
      _recipeById = await recipeModel.postLike(recipeId);
    } catch (e) {
      likesInARecipeError = true;
      toggleLikeInRecipeById(); // in case the like operation fails in backend
    } finally {
      notifyListeners();
    }
  }

  getIsLikedForRecipe(BuildContext context) {
    final userAuthViewModel = context.read<UserAuthViewModel>();
    if (recipeById!.likeIds!.contains(userAuthViewModel.currentUser!.id)) {
      isRecipeLiked = true;
    } else {
      isRecipeLiked = false;
    }
    notifyListeners();
  }

  toggleLikeInRecipeById() {
    isRecipeLiked = !isRecipeLiked;
    notifyListeners();
  }

  void searchForRecipes(String query) async {
    // Cancel the previous timer if it exists
    timer?.cancel();

    // Reset the state for a new search
    searchRecipesError = false;
    searchRecipesLoading = true;
    notifyListeners();

    if (query.isEmpty) {
      _searchRecipes = [];
      searchRecipesLoading = false; // No need to keep loading state
      notifyListeners();
      return;
    }

    // Debounce the API call
    timer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final results = await recipeModel.searchForRecipes(query);
        _searchRecipes = results;
      } catch (e) {
        searchRecipesError = true;
        _searchRecipes = [];
      } finally {
        searchRecipesLoading = false;
        notifyListeners(); // Notify after all updates are complete
      }
    });
  }
}
