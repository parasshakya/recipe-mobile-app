import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/viewModels/socket_view_model.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';
import 'package:recipe_flutter_app/widgets/recipe_card.dart';
import 'package:recipe_flutter_app/utils.dart';
import 'package:recipe_flutter_app/viewModels/recipe_view_model.dart';
import 'package:recipe_flutter_app/views/recipe_detail_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late UserAuthViewModel userAuthViewModel;
  late RecipeViewModel recipeViewModel;
  late SocketViewModel socketViewModel;

  ScrollController scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  fetchRecipes({bool isRefresh = false}) async {
    if (isRefresh) {
      recipeViewModel.clearRecipes();
      recipeViewModel.currentPage = 1;
    }

    await recipeViewModel.loadAllRecipes();
    if (recipeViewModel.hasMore) {
      recipeViewModel.currentPage++;
    }
  }

  @override
  void initState() {
    userAuthViewModel = Provider.of<UserAuthViewModel>(context, listen: false);
    recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
    socketViewModel = Provider.of<SocketViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchRecipes();
      scrollController.addListener(() {
        if (scrollController.position.pixels ==
                scrollController.position.maxScrollExtent &&
            !recipeViewModel.loading &&
            recipeViewModel.hasMore) {
          fetchRecipes();
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessary for AutomaticKeepAliveClientMixin
    return SafeArea(
        child: Scaffold(
      body: RefreshIndicator(onRefresh: () async {
        fetchRecipes(isRefresh: true);
      }, child: Consumer<RecipeViewModel>(builder: (context, value, child) {
        if (value.loading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (value.recipesError) {
          showSnackbar(
              "Failed to load recipe, Please try again later.", context);
          return const Center(
            child: Text("Failed to load recipes, Please try again later"),
          );
        }

        if (value.totalRecipeCount == 0) {
          return const Center(child: Text("no recipes found "));
        }
        return ListView.builder(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: value.recipes.length + (value.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == value.recipes.length) {
                return const SpinKitThreeBounce(
                  color: Colors.red,
                  size: 40,
                );
              }

              final recipe = value.recipes[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          RecipeDetailScreen(recipeId: recipe.id)));
                },
                child: RecipeCard(
                    name: recipe.name,
                    imageUrl: recipe.image,
                    description: recipe.description),
              );
            });
      })),
    ));
  }
}
