import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/screens/login_screen.dart';
import 'package:recipe_flutter_app/screens/otp_verification_screen.dart';
import 'package:recipe_flutter_app/utils.dart';
import 'package:recipe_flutter_app/screens/home_screen.dart';
import 'package:recipe_flutter_app/services/api_services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AuthProvider authProvider;
  XFile? image;

  Future<void> _signUp() async {
    if (image == null) {
      showSnackbar("Please select an image", context);
      return;
    }
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;

      try {
        final response =
            await ApiService().fetchOTP(email, password, name, image!);
        if (response.statusCode == 200) {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => OTPVerificationScreen(email: email)));
        }
      } catch (e) {
        showSnackbar(e.toString(), context);
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed up as $name with email: $email')),
      );

      // Navigator.of(context)
      //     .push(MaterialPageRoute(builder: (context) => HomeScreen()));
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: pickImage,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey.shade300,
                          radius: 50,
                          backgroundImage: image != null
                              ? FileImage(File(image!.path))
                              : null,
                          child: image == null
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey.shade400,
                            radius: 20,
                            child: Icon(
                              Icons.edit,
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Name",
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
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
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20.0),
                  Container(
                    width: 200,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade200),
                      onPressed: _signUp,
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an account?"),
                      const SizedBox(width: 4.0),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LoginScreen()));
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
