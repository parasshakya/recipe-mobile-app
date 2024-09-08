import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:recipe_flutter_app/config/config.dart';
import 'package:recipe_flutter_app/constants.dart';
import 'package:recipe_flutter_app/models/recipe.dart';
import 'package:recipe_flutter_app/screens/user_detail_screen.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailScreen({required this.recipe, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.network(
                "${Config.baseUrl}/uploads/${recipe.image}",
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                recipe.name,
                style: TextStyle(fontSize: 30),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    "${Config.baseUrl}/uploads/${recipe.user.image}",
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailScreen(user: recipe.user)));
                      },
                      child: Text(recipe.user.username)),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Text(recipe.description),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
