import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/constants.dart';
import 'package:recipe_flutter_app/models/user.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;
  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  User? _user;
  bool _loading = true;

  fetchUser() async {
    try {
      _user = await Provider.of<AuthProvider>(context, listen: false)
          .getUserById(widget.user.id);
      setState(() {});
    } catch (e) {
      showSnackbar(e.toString(), context);
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  followUser() async {
    try {} catch (e) {}
  }

  @override
  void initState() {
    fetchUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: _loading
            ? CircularProgressIndicator()
            : Column(
                children: [
                  Text(_user!.username),
                  ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.add),
                      label: Text('Follow'))
                ],
              ),
      ),
    );
  }
}
