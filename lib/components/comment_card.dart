import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/models/comment.dart';
import 'package:recipe_flutter_app/models/recipe.dart';
import 'package:recipe_flutter_app/models/user.dart';
import 'package:recipe_flutter_app/services/api_services.dart';

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
    user = await ApiService().getUserById(widget.comment.userId);
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
