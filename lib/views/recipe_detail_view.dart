import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/viewModels/category_view_model.dart';
import 'package:recipe_flutter_app/viewModels/cuisine_view_model.dart';
import 'package:recipe_flutter_app/viewModels/recipe_view_model.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';
import 'package:recipe_flutter_app/widgets/comment_card.dart';
import 'package:recipe_flutter_app/schemas/category.dart';
import 'package:recipe_flutter_app/schemas/comment.dart';
import 'package:recipe_flutter_app/schemas/cuisine.dart';
import 'package:recipe_flutter_app/schemas/user.dart';
import 'package:recipe_flutter_app/views/user_detail_view.dart';

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
  User? user;
  late UserAuthViewModel userAuthViewModel;
  late RecipeViewModel recipeViewModel;
  late CategoryViewModel categoryViewModel;
  late CuisineViewModel cuisineViewModel;
  bool loading = true;
  Cuisine? cuisine;
  Category? category;
  List<Comment> comments = [];

  @override
  void initState() {
    userAuthViewModel = Provider.of<UserAuthViewModel>(context, listen: false);
    recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
    categoryViewModel = Provider.of<CategoryViewModel>(context, listen: false);
    cuisineViewModel = Provider.of<CuisineViewModel>(context, listen: false);

    fetchData();
    super.initState();

    // Check if the user has liked the recipe. This can be retrieved from the API.
  }

  fetchRecipe() async {
    await recipeViewModel.getById(widget.recipeId);
  }

  fetchComments() async {
    await recipeViewModel.loadCommentsInARecipe(widget.recipeId);
  }

  fetchCategory() async {
    category = await categoryViewModel
        .loadCategory(recipeViewModel.recipeById!.categoryId);
  }

  fetchData() async {
    await fetchRecipe();
    await fetchUser();
    await fetchCuisine();
    await fetchCategory();

    getLiked();

    await fetchComments();

    loading = false;
    setState(() {});
  }

  getLiked() {
    if (recipeViewModel.recipeById!.likeIds!
        .contains(userAuthViewModel.currentUser!.id)) {
      isLiked = true;
    } else {
      isLiked = false;
    }
  }

  fetchCuisine() async {
    cuisine = await cuisineViewModel
        .loadCuisine(recipeViewModel.recipeById!.cuisineId);
  }

  fetchUser() async {
    user =
        await userAuthViewModel.getUserById(recipeViewModel.recipeById!.userId);
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
      await recipeViewModel.postLikes(widget.recipeId);
    } catch (e) {
      setState(() {
        isLiked = !isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(user!.image),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UserDetailScreen(userId: user!.id),
                              ),
                            );
                          },
                          child: Text(
                            user!.username,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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
                        "Category: ${category!.name}",
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Cuisine: ${cuisine!.name}",
                        style: const TextStyle(fontSize: 20),
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
                        Text(
                            "${recipeViewModel.recipeById!.likeIds!.length} Likes"),
                      ],
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
                    Column(
                      children: comments.map((comment) {
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
