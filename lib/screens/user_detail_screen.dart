import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/components/recipe_card_user_detail.dart';
import 'package:recipe_flutter_app/models/recipe.dart';
import 'package:recipe_flutter_app/providers/recipe_provider.dart';
import 'package:recipe_flutter_app/screens/private_chat_screen.dart';
import 'package:recipe_flutter_app/screens/recipe_detail_screen.dart';
import 'package:recipe_flutter_app/services/api_services.dart';
import 'package:recipe_flutter_app/utils.dart';
import 'package:recipe_flutter_app/models/user.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';

class UserDetailScreen extends StatefulWidget {
  final String userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  User? _user;
  User? currentUser;
  bool _loading = true;
  List<Recipe> recipes = [];
  bool following = false;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      await fetchUser();
      await fetchCurrentUser();
      await getRecipesByUser();
      checkFollowingStatus();
    } catch (e) {
      showSnackbar("Something went wrong", context);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      final currentUserId =
          Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
      currentUser = await ApiService().getUserById(currentUserId);
    } catch (e) {
      showSnackbar("Failed to get current user", context);
    }
  }

  Future<void> fetchUser() async {
    try {
      _user = await ApiService().getUserById(widget.userId);
    } catch (e) {
      showSnackbar(e.toString(), context);
    }
  }

  Future<void> getRecipesByUser() async {
    try {
      recipes = await ApiService().getRecipesByUser(userId: widget.userId);
    } catch (e) {
      showSnackbar("Failed to fetch recipes", context);
    }
  }

  void checkFollowingStatus() {
    if (currentUser?.following.contains(widget.userId) == true) {
      setState(() {
        following = true;
      });
    } else {
      setState(() {
        following = false;
      });
    }
  }

  Future<void> followUser() async {
    try {
      await authProvider.followUser(widget.userId);
      await fetchData();
    } catch (e) {
      showSnackbar(e.toString(), context);
    }
  }

  Future<void> unfollowUser() async {
    try {
      await authProvider.unfollowUser(widget.userId);
      await fetchData();
    } catch (e) {
      showSnackbar(e.toString(), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: _loading
            ? CircularProgressIndicator()
            : RefreshIndicator(
                onRefresh: () async {
                  fetchData();
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _user?.image != null
                            ? NetworkImage(_user!.image)
                            : null,
                      ),
                      SizedBox(height: 10),
                      Text(
                        _user?.username ?? "Loading...",
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Followers: ${_user?.followers.length ?? 0}",
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(width: 20),
                          Text(
                            "Following: ${_user?.following.length ?? 0}",
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: following ? unfollowUser : followUser,
                            icon: Icon(following ? Icons.check : Icons.add),
                            label: Text(following ? "Following" : "Follow"),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => PrivateChatScreen(
                                      receiverUserId: widget.userId)));
                            },
                            icon: Icon(Icons.message),
                            label: Text("message"),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = recipes[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecipeDetailScreen(recipeId: recipe.id),
                                ),
                              );
                            },
                            child: RecipeCardUserDetail(
                              name: recipe.name,
                              imageUrl: recipe.image,
                              description: recipe.description,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
