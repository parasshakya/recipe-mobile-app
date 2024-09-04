import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/components/RecipeCard.dart';
import 'package:recipe_flutter_app/constants.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;
  late AuthProvider authProvider;
  late RecipeProvider recipeProvider;

  fetchRecipes() async {
    recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
    await recipeProvider.fetchAllRecipes();
    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    PushNotificationService().init();
    fetchRecipes();
    super.initState();
  }

  logout() async {
    try {
      await authProvider.logout();
      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
    } catch (e) {
      showSnackbar(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<AuthProvider>(context);
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text("Home"),
            actions: [
              Text(authProvider.user!.username),
              const SizedBox(
                width: 8,
              ),
              ElevatedButton(
                  onPressed: () {
                    logout();
                  },
                  child: const Text("Logout"))
            ],
          ),
          body: loading
              ? Center(child: const CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      ...recipeProvider.recipes.map((e) => GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      RecipeDetailScreen(recipe: e)));
                            },
                            child: RecipeCard(
                                name: e.name,
                                imageUrl: e.image,
                                description: e.description),
                          ))
                    ],
                  ),
                )),
    );
  }
}
