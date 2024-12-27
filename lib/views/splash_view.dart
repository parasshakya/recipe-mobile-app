import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/viewModels/user_auth_view_model.dart';
import 'package:recipe_flutter_app/views/login_view.dart';
import 'package:recipe_flutter_app/views/navigation_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Widget? screen;
  bool loading = true;

  buildScreen() async {
    final userViewModel =
        Provider.of<UserAuthViewModel>(context, listen: false);

    final isUser = await userViewModel.checkUser();
    if (isUser) {
      screen = const NavigationScreen();
    } else {
      screen = const LoginScreen();
    }
    setState(() {
      loading = false;
    });
  }

  @override
  void initState() {
    buildScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.amber,
        body: Center(
          child: Icon(
            Icons.food_bank_rounded,
            size: 180,
            color: Colors.white,
          ),
        ),
      );
    } else {
      return screen!;
    }
  }
}
