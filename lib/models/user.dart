import 'package:recipe_flutter_app/models/notification.dart';

class User {
  final String id;
  final String username;
  final String? bio;
  final String email;
  final String image;
  final List? savedRecipes;
  final List<String> followers;
  final List<String> following;
  final List<UserNotification>? notifications;

  User(
      {required this.id,
      required this.username,
      this.bio,
      required this.email,
      required this.image,
      this.notifications,
      this.savedRecipes,
      required this.followers,
      required this.following});

  // Factory constructor to create a User object from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["_id"],
      username: json['username'],
      email: json['email'],
      bio: json["bio"],
      image: json['image'],
      savedRecipes:
          json['savedRecipes'] != null ? List.from(json['savedRecipes']) : null,
      followers: json['followers'] != null ? List.from(json["followers"]) : [],
      following: json['following'] != null ? List.from(json["following"]) : [],
      notifications: json["notifications"] != null
          ? (json["notifications"] as List)
              .map((e) => UserNotification.fromJson(e))
              .toList()
          : [],
    );
  }

  // Method to convert a User object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      "id": id,
      'username': username,
      'email': email,
      "bio": bio,
      'image': image,
      'savedRecipes': savedRecipes,
      'followers': followers,
      'following': following,
    };
  }
}
