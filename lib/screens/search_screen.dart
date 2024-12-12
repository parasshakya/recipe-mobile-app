import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/models/recipe.dart';
import 'package:recipe_flutter_app/screens/recipe_detail_screen.dart';
import 'package:recipe_flutter_app/services/api_services.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Recipe> recipes = [];

  searchRecipes(String query) async {
    if (query.isEmpty) {
      setState(() {
        recipes = [];
      });
    } else {
      recipes = await ApiService().searchForRecipes(query);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search for recipes",
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
            onChanged: (query) {
              searchRecipes(query);
            },
          ),
          SizedBox(
            height: 10,
          ),
          if (recipes.isNotEmpty)
            ListView.builder(
                shrinkWrap: true,
                itemCount: recipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailScreen(recipeId: recipe.id)));
                    },
                    tileColor: Colors.grey.shade200,
                    title: Text(recipe.name),
                  );
                })
        ],
      ),
    ));
  }
}
