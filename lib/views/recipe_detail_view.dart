import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/utils.dart';
import 'package:recipe_flutter_app/viewModels/category_view_model.dart';
import 'package:recipe_flutter_app/viewModels/cuisine_view_model.dart';
import 'package:recipe_flutter_app/viewModels/recipe_view_model.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';
import 'package:recipe_flutter_app/widgets/comment_card.dart';
import 'package:recipe_flutter_app/schemas/comment.dart';
import 'package:recipe_flutter_app/schemas/user.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({required this.recipeId, Key? key})
      : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  TextEditingController commentController = TextEditingController();
  User? user;
  late UserAuthViewModel userAuthViewModel;
  late CategoryViewModel categoryViewModel;
  late CuisineViewModel cuisineViewModel;
  late RecipeViewModel recipeViewModel;

  @override
  void initState() {
    userAuthViewModel = context.read<UserAuthViewModel>();
    categoryViewModel = context.read<CategoryViewModel>();
    cuisineViewModel = context.read<CuisineViewModel>();
    recipeViewModel = context.read<RecipeViewModel>();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      recipeViewModel.initializeRecipe(widget.recipeId, context);
    });

    super.initState();
  }

  void postComment() async {
    String commentText = commentController.text.trim();
    if (commentText.isNotEmpty) {
      // Call API to post the comment.
      await recipeViewModel.postComment(widget.recipeId, commentText);

      // Add the new comment locally to the state.
      setState(() {
        commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    recipeViewModel = context.watch<RecipeViewModel>();
    return recipeViewModel.initRecipeLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : recipeViewModel.initRecipeError
            ? buildErrorMessage()
            : Scaffold(
                appBar: AppBar(
                  title: Text(recipeViewModel.recipeById!.name),
                ),
                body: SafeArea(
                  child: SingleChildScrollView(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        recipeViewModel.recipeById!.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          recipeViewModel.recipeById!.name,
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          userAuthViewModel.recipeUser!.username,
                          style: const TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          recipeViewModel.recipeById!.description,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Category: ${categoryViewModel.categoryById!.name}",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Cuisine: ${cuisineViewModel.cuisineById!.name}",
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      Consumer<RecipeViewModel>(
                        builder: (context, value, child) => Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                value.isRecipeLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: value.isRecipeLiked
                                    ? Colors.red
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                value.postLikes(widget.recipeId);
                              },
                            ),
                            Text(" ${value.recipeById!.likeIds!.length} Likes")
                          ],
                        ),
                      ),
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Comments",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Consumer<RecipeViewModel>(
                        builder: (context, value, child) =>
                            value.commentsInARecipeLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : value.commentsInARecipeError
                                    ? const Center(
                                        child: Text(
                                            "Failed to load comments, Please try again later."),
                                      )
                                    : Column(
                                        children: value.commentsInARecipe
                                            .map((comment) {
                                          return CommentCard(comment: comment);
                                        }).toList(),
                                      ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: commentController,
                                decoration: const InputDecoration(
                                  labelText: "Post a comment",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: postComment,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
                ),
              );
  }

  buildErrorMessage() {
    showSnackbar("Something went wrong, Please try again later.", context);
    return const Scaffold(
      body: Center(
        child: Text('Something went wrong, Please try again later'),
      ),
    );
  }
}
