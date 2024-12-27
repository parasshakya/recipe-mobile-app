import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/schemas/recipe.dart';
import 'package:recipe_flutter_app/viewModels/recipe_view_model.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';
import 'package:recipe_flutter_app/views/edit_profile_view.dart';
import 'package:recipe_flutter_app/utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserAuthViewModel userAuthViewModel;
  late RecipeViewModel recipeViewModel;
  List<Recipe> recipes = [];
  bool recipeLoading = true;

  @override
  void initState() {
    userAuthViewModel = Provider.of<UserAuthViewModel>(context, listen: false);
    recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
    fetchRecipesOfCurrentUser();
    super.initState();
  }

  fetchRecipesOfCurrentUser() async {
    try {
      recipes = await recipeViewModel
          .getRecipesByUser(userAuthViewModel.currentUser!.id);
    } catch (e) {
      showSnackbar("Could not fetch recipes. Please try again later.", context);
    } finally {
      recipeLoading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage:
                    NetworkImage(userAuthViewModel.currentUser!.image),
                radius: 50,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    recipeLoading
                        ? CircularProgressIndicator()
                        : Text(
                            recipes.length.toString(),
                            style: TextStyle(fontSize: 24),
                          ),
                    Text(
                      "posts",
                      style: TextStyle(fontSize: 24),
                    )
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  children: [
                    Text(
                      "${userAuthViewModel.currentUser!.followers.length}",
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(
                      "followers",
                      style: TextStyle(fontSize: 24),
                    )
                  ],
                ),
                SizedBox(
                  width: 20,
                ),
                Column(
                  children: [
                    Text(
                      "${userAuthViewModel.currentUser!.following.length}",
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(
                      "following",
                      style: TextStyle(fontSize: 24),
                    )
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => EditProfileScreen()));
                },
                child: Text("Edit profile")),
            SizedBox(
              height: 30,
            ),
            Container(
              height: 50,
              color: Colors.grey.shade300,
              child: Center(
                child: Icon(
                  Icons.fastfood_rounded,
                  color: Colors.black,
                ),
              ),
            ),
            recipeLoading
                ? Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : recipes.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Center(
                          child: Text("No posts to show"),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: recipes.length,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final recipe = recipes[index];
                          return Image.network(recipe.image);
                        })
          ],
        ),
      ),
    );
  }
}
