import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/components/recipe_card.dart';
import 'package:recipe_flutter_app/models/notification.dart';
import 'package:recipe_flutter_app/screens/chat_room_screen.dart';
import 'package:recipe_flutter_app/screens/notification_screen.dart';
import 'package:recipe_flutter_app/services/chat_service.dart';
import 'package:recipe_flutter_app/utils.dart';
import 'package:recipe_flutter_app/models/recipe.dart';
import 'package:recipe_flutter_app/models/user.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/providers/recipe_provider.dart';
import 'package:recipe_flutter_app/screens/login_screen.dart';
import 'package:recipe_flutter_app/screens/recipe_detail_screen.dart';
import 'package:recipe_flutter_app/services/api_services.dart';
import 'package:recipe_flutter_app/services/push_notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late AuthProvider authProvider;
  late RecipeProvider recipeProvider;
  final chatService = ChatService();

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
      recipeProvider.clearRecipes();
      recipeProvider.currentPage = 1;
    }

    setState(() {});

    try {
      recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
      await recipeProvider.fetchAllRecipes();
      if (recipeProvider.hasMore) {
        recipeProvider.currentPage++;
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
          recipeProvider.hasMore) {
        fetchRecipes();
      }
    });
    super.initState();
  }

  logout() async {
    try {
      await authProvider.logout();
      chatService.dispose(); // socket connection for chat is disposed
    } catch (e) {
      showSnackbar(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Necessary for AutomaticKeepAliveClientMixin
    authProvider = Provider.of<AuthProvider>(context);
    recipeProvider = Provider.of<RecipeProvider>(context);
    return SafeArea(
        child: Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          fetchRecipes(isRefresh: true);
        },
        child: loading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : recipeProvider.totalRecipeCount == 0
                ? Center(child: Text("no recipes found "))
                : ListView.builder(
                    controller: scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    itemCount: recipeProvider.recipes.length +
                        (recipeProvider.hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == recipeProvider.recipes.length) {
                        return SpinKitThreeBounce(
                          color: Colors.red,
                          size: 40,
                        );
                      }

                      final recipe = recipeProvider.recipes[index];
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
