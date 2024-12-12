import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/services/api_services.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late AuthProvider authProvider;
  XFile? image;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // updateUser(String username, String bio) async {
  //   try {
  //     await ApiService().updateUser(
  //       username,
  //       bio,
  //       image!.path
  //     );
  //   } catch (e) {}
  // }

  pickImage() async {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit profile"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            image == null
                ? CircleAvatar(
                    backgroundImage:
                        NetworkImage(authProvider.currentUser!.image),
                    radius: 50,
                  )
                : CircleAvatar(
                    backgroundImage: FileImage(File(image!.path)),
                    radius: 50,
                  ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                pickImage();
              },
              child: Text(
                "Change picture",
                style: TextStyle(
                    color: Colors.blue.shade400,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            buildInputFields(),
            SizedBox(
              height: 20,
            ),
            Container(
              width: 200,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade200),
                  onPressed: () {},
                  child: Text(
                    "Update",
                    style: TextStyle(color: Colors.black),
                  )),
            )
          ],
        ),
      ),
    );
  }

  buildInputFields() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          TextFormField(
            initialValue: authProvider.currentUser!.username,
            decoration: InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
          SizedBox(
            height: 14,
          ),
          TextFormField(
            decoration: InputDecoration(
                labelText: "Bio",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
        ],
      ),
    );
  }
}
