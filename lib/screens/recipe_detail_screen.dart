import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:recipe_flutter_app/config/config.dart';
import 'package:recipe_flutter_app/utils.dart';
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
                recipe.image,
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
                  CircleAvatar(
                      radius: 25,
                      backgroundImage: NetworkImage(recipe.user.image)),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailScreen(user: recipe.user)));
                      },
                      child: Text(
                        recipe.user.username,
                        style: TextStyle(fontSize: 18),
                      )),
                ],
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                recipe.description,
                style: TextStyle(fontSize: 20),
              ),
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
