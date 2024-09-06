import 'package:recipe_flutter_app/models/category.dart';
import 'package:recipe_flutter_app/models/cuisine.dart';
import 'package:recipe_flutter_app/models/user.dart';

class Recipe {
  final String id;
  final User user;
  final Cuisine cuisine;
  final String description;
  final String name;
  final List<String> instructions; // List of instructions
  final List<String> ingredients; // List of ingredients
  final String image;
  final List<Comment> comments;
  final List<User> likes;
  final int preparingTimeInHours;
  final int preparingTimeInMinutes;
  final int preparingTimeInSeconds;
  final int cookingTimeInHours;
  final int cookingTimeInMinutes;
  final int cookingTimeInSeconds;
  final Category category;

  Recipe({
    required this.id,
    required this.user,
    required this.cuisine,
    required this.description,
    required this.name,
    required this.instructions,
    required this.ingredients,
    required this.image,
    required this.comments,
    required this.likes,
    required this.preparingTimeInHours,
    required this.preparingTimeInMinutes,
    required this.preparingTimeInSeconds,
    required this.cookingTimeInHours,
    required this.cookingTimeInMinutes,
    required this.cookingTimeInSeconds,
    required this.category,
  });

  // Factory constructor to create a Recipe object from JSON
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['_id'],
      user: User.fromJson(json['user']),
      cuisine: Cuisine.fromJson(json['cuisine']),
      description: json['description'],
      name: json['name'],
      instructions: List<String>.from(json['instructions']),
      ingredients: List<String>.from(json['ingredients']),
      image: json['image'],
      comments: (json['comments'] as List)
          .map((comment) => Comment.fromJson(comment))
          .toList(),
      likes:
          (json['likes'] as List).map((like) => User.fromJson(like)).toList(),
      preparingTimeInHours: json['preparingTimeInHours'] ?? 0,
      preparingTimeInMinutes: json['preparingTimeInMinutes'] ?? 0,
      preparingTimeInSeconds: json['preparingTimeInSeconds'] ?? 0,
      cookingTimeInHours: json['cookingTimeInHours'] ?? 0,
      cookingTimeInMinutes: json['cookingTimeInMinutes'] ?? 0,
      cookingTimeInSeconds: json['cookingTimeInSeconds'] ?? 0,
      category: Category.fromJson(json['category']),
    );
  }

  // Method to convert a Recipe object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user.toJson(),
      'cuisine': cuisine.toJson(),
      'description': description,
      'name': name,
      'instructions': instructions,
      'ingredients': ingredients,
      'image': image,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'likes': likes,
      'preparingTimeInHours': preparingTimeInHours,
      'preparingTimeInMinutes': preparingTimeInMinutes,
      'preparingTimeInSeconds': preparingTimeInSeconds,
      'cookingTimeInHours': cookingTimeInHours,
      'cookingTimeInMinutes': cookingTimeInMinutes,
      'cookingTimeInSeconds': cookingTimeInSeconds,
      'category': category.toJson(),
    };
  }
}

// Comment model
class Comment {
  final User user;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.user,
    required this.text,
    required this.createdAt,
  });

  // Factory constructor to create a Comment object from JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      user: User.fromJson(json['user']),
      text: json['text'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Method to convert a Comment object to JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
