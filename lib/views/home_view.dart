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
  bool loading = true;
  // List<UserNotification> notifications = [];

  bool fetchMoreLoading = false;

  @override
  bool get wantKeepAlive => true;

  fetchRecipes({bool isRefresh = false}) async {
    if (fetchMoreLoading) {
      return;
    }
    fetchMoreLoading = true;

    if (isRefresh) {
      recipeViewModel.clearRecipes();
      recipeViewModel.currentPage = 1;
    }

    setState(() {});

    try {
      recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
      await recipeViewModel.loadAllRecipes();
      if (recipeViewModel.hasMore) {
        recipeViewModel.currentPage++;
      }
    } catch (e) {
      showSnackbar("Error fetching recipes", context);
    } finally {
      setState(() {
        fetchMoreLoading = false;
        loading = false;
      });
    }
  }

  @override
  void initState() {
    fetchRecipes();
    // fetchNotifications();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !fetchMoreLoading &&
          recipeViewModel.hasMore) {
        fetchRecipes();
      }
    });
    super.initState();
  }

  logout() async {
    try {
      await userAuthViewModel.logout();
      socketViewModel.dispose(); // socket connection for chat is disposed
    } catch (e) {
      showSnackbar(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessary for AutomaticKeepAliveClientMixin
    userAuthViewModel = Provider.of<UserAuthViewModel>(context);
    recipeViewModel = Provider.of<RecipeViewModel>(context);
    return SafeArea(
        child: Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          fetchRecipes(isRefresh: true);
        },
        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : recipeViewModel.totalRecipeCount == 0
                ? Center(child: Text("no recipes found "))
                : ListView.builder(
                    controller: scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: recipeViewModel.recipes.length +
                        (recipeViewModel.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == recipeViewModel.recipes.length) {
                        return const SpinKitThreeBounce(
                          color: Colors.red,
                          size: 40,
                        );
                      }

                      final recipe = recipeViewModel.recipes[index];
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
                    }),
      ),
    ));
  }
}
