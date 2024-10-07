import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/components/comment_card.dart';
import 'package:recipe_flutter_app/models/recipe.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/screens/user_detail_screen.dart';
import 'package:recipe_flutter_app/services/api_services.dart';
import 'package:recipe_flutter_app/utils.dart'; // For helper functions like showToast or formatting.

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({required this.recipeId, Key? key})
      : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  TextEditingController commentController = TextEditingController();
  bool isLiked = false; // Track if the user has liked the recipe.
  Recipe? recipe;
  late AuthProvider authProvider;
  bool loading = true;

  @override
  void initState() {
    fetchRecipe();
    super.initState();

    // Check if the user has liked the recipe. This can be retrieved from the API.
  }

  fetchRecipe() async {
    recipe = await ApiService().getRecipeById(widget.recipeId);
    getLiked();
    loading = false;
    setState(() {});
  }

  getLiked() {
    authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (recipe!.likes.contains(authProvider.currentUser!.id)) {
      isLiked = true;
    } else {
      isLiked = false;
    }
    setState(() {});
  }

  void postComment() async {
    String commentText = commentController.text.trim();
    if (commentText.isNotEmpty) {
      // Call API to post the comment.
      final recipeResponse =
          await ApiService().postComment(widget.recipeId, commentText);

      // Add the new comment locally to the state.
      setState(() {
        recipe = recipeResponse;

        commentController.clear();
      });
      // showToast("Comment posted successfully!");
    }
  }

  void toggleLike() async {
    // Toggle like status locally for quick feedback.
    setState(() {
      isLiked = !isLiked;
    });

    try {
      // Call API to like/unlike the recipe.
      final recipeResponse = await ApiService().postLike(widget.recipeId);
      setState(() {
        recipe = recipeResponse;
      });
    } catch (e) {
      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Text(recipe!.name),
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      recipe!.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 200,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        recipe!.name,
                        style: TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(recipe!.user.image),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailScreen(userId: recipe!.user.id),
                              ),
                            );
                          },
                          child: Text(
                            recipe!.user.username,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        recipe!.description,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? Colors.red : Colors.grey,
                          ),
                          onPressed: toggleLike,
                        ),
                        Text("${recipe!.likes.length} Likes"),
                      ],
                    ),
                    Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Comments",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      children: recipe!.comments.map((comment) {
                        return CommentCard(comment: comment);
                      }).toList(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                labelText: "Post a comment",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send),
                            onPressed: postComment,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
