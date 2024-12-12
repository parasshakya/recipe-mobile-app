import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/screens/navigation_screen.dart';
import 'package:recipe_flutter_app/utils.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/screens/home_screen.dart';
import 'package:recipe_flutter_app/screens/signup_screen.dart';
import 'package:recipe_flutter_app/services/api_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final apiService = ApiService();
  late AuthProvider authProvider;

  handleSignIn() async {
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      final googleAccount = await googleSignIn.signIn();

      final googleSignInAuth = await googleAccount?.authentication;

// We will use this ID token for authentication on the backend side.

      final idToken = googleSignInAuth?.idToken;

      if (idToken != null) {
        await authProvider.signInWithGoogle(idToken);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => NavigationScreen()));
      }
    } catch (e) {
      print("Error while signing in. Please try again later.");
    }
  }

  void _login() async {
    try {
      if (_formKey.currentState!.validate()) {
        String email = _emailController.text;
        String password = _passwordController.text;

        await authProvider.login(email, password);

        if (!mounted) return;

        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => NavigationScreen()));

        showSnackbar("Succesfully Logged in", context);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Login Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.food_bank_rounded,
                    size: 80,
                    color: Colors.amber.shade700,
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 50.0),
                  Container(
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade200),
                      onPressed: _login,
                      child: const Text(
                        "Login",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?"),
                      const SizedBox(width: 4.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => SignUpScreen()));
                        },
                        child: const Text(
                          "Signup",
                          style: TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 14,
                  ),
                  Text("OR"),
                  SizedBox(
                    height: 14,
                  ),
                  Container(
                    width: 200,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber.shade200),
                        onPressed: () {
                          handleSignIn();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FaIcon(FontAwesomeIcons.google),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Login with google",
                              style: TextStyle(color: Colors.black),
                            ),
                          ],
                        )),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
