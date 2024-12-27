import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/utils.dart';
import 'package:recipe_flutter_app/viewModels/recipe_view_model.dart';
import 'package:recipe_flutter_app/views/recipe_detail_view.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

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
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
            onChanged: (query) {
              context.read<RecipeViewModel>().searchForRecipes(query);
            },
          ),
          const SizedBox(
            height: 10,
          ),
          Consumer<RecipeViewModel>(builder: (context, recipeViewModel, child) {
            if (recipeViewModel.searchRecipesLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (recipeViewModel.searchRecipesError != null) {
              showSnackbar("Something went wrong", context);
              return Text(recipeViewModel.searchRecipesError!);
            }

            return ListView.builder(
                shrinkWrap: true,
                itemCount: recipeViewModel.searchRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = recipeViewModel.searchRecipes[index];
                  return ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) =>
                              RecipeDetailScreen(recipeId: recipe.id)));
                    },
                    tileColor: Colors.grey.shade200,
                    title: Text(recipe.name),
                  );
                });
          }),
        ],
      ),
    ));
  }
}
