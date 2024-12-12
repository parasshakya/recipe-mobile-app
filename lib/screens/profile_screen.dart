import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/models/recipe.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/screens/edit_profile_screen.dart';
import 'package:recipe_flutter_app/services/api_services.dart';
import 'package:recipe_flutter_app/utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late AuthProvider authProvider;
  List<Recipe> recipes = [];
  bool recipeLoading = true;

  @override
  void initState() {
    fetchRecipesOfCurrentUser();
    super.initState();
  }

  fetchRecipesOfCurrentUser() async {
    try {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      recipes = await ApiService()
          .getRecipesByUser(userId: authProvider.currentUser!.id);
    } catch (e) {
      showSnackbar("Could not fetch recipes. Please try again later.", context);
    } finally {
      recipeLoading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: NetworkImage(authProvider.currentUser!.image),
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
                      "${authProvider.currentUser!.followers.length}",
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
                      "${authProvider.currentUser!.following.length}",
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
