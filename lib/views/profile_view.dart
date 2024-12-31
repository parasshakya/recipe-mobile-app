import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/viewModels/recipe_view_model.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';
import 'package:recipe_flutter_app/views/edit_profile_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late UserAuthViewModel userAuthViewModel;
  late RecipeViewModel recipeViewModel;

  @override
  void initState() {
    userAuthViewModel = context.read<UserAuthViewModel>();
    recipeViewModel = context.read<RecipeViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      recipeViewModel.getRecipesByUser(userAuthViewModel.currentUser!.id);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    recipeViewModel = context.watch<RecipeViewModel>();

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
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    recipeViewModel.recipesByUserLoading
                        ? const CircularProgressIndicator()
                        : Text(
                            recipeViewModel.recipesByUser.length.toString(),
                            style: const TextStyle(fontSize: 24),
                          ),
                    const Text(
                      "posts",
                      style: TextStyle(fontSize: 24),
                    )
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  children: [
                    Text(
                      "${userAuthViewModel.currentUser!.followers.length}",
                      style: const TextStyle(fontSize: 24),
                    ),
                    const Text(
                      "followers",
                      style: TextStyle(fontSize: 24),
                    )
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
                Column(
                  children: [
                    Text(
                      "${userAuthViewModel.currentUser!.following.length}",
                      style: const TextStyle(fontSize: 24),
                    ),
                    const Text(
                      "following",
                      style: TextStyle(fontSize: 24),
                    )
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const EditProfileScreen()));
                },
                child: const Text("Edit profile")),
            const SizedBox(
              height: 30,
            ),
            Container(
              height: 50,
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(
                  Icons.fastfood_rounded,
                  color: Colors.black,
                ),
              ),
            ),
            recipeViewModel.recipesByUserLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : recipeViewModel.recipesByUserError
                    ? const Center(
                        child: Text("Error while fetching recipes"),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: recipeViewModel.recipesByUser.length,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final recipe = recipeViewModel.recipesByUser[index];
                          return Image.network(recipe.image);
                        })
          ],
        ),
      ),
    );
  }
}
