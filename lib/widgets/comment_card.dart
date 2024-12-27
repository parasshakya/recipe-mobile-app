import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/schemas/comment.dart';
import 'package:recipe_flutter_app/schemas/recipe.dart';
import 'package:recipe_flutter_app/schemas/user.dart';
import 'package:recipe_flutter_app/models/api_model.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  const CommentCard({super.key, required this.comment});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  User? user;
  bool loading = true;

  fetchUser() async {
    user = await Provider.of<UserAuthViewModel>(context, listen: false)
        .getUserById(widget.comment.userId);
    loading = false;
    setState(() {});
  }

  @override
  void initState() {
    fetchUser();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? CircularProgressIndicator()
        : Card(
            child: ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(user!.image),
              ),
              title: Text(user!.username),
              subtitle: Text(widget.comment.text),
            ),
          );
  }
}
