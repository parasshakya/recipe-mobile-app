import 'package:recipe_flutter_app/models/category.dart';
import 'package:recipe_flutter_app/models/comment.dart';
import 'package:recipe_flutter_app/models/cuisine.dart';
import 'package:recipe_flutter_app/models/user.dart';

class Recipe {
  final String id;
  final String userId;
  final String cuisineId;
  final String description;
  final String name;
  final List<String> instructions; // List of instructions
  final List<String> ingredients; // List of ingredients
  final String image;
  final List<String>? commentIds;
  final List<String>? likeIds;
  final int preparingTimeInHours;
  final int preparingTimeInMinutes;
  final int preparingTimeInSeconds;
  final int cookingTimeInHours;
  final int cookingTimeInMinutes;
  final int cookingTimeInSeconds;
  final String categoryId;

  Recipe({
    required this.id,
    required this.userId,
    required this.cuisineId,
    required this.description,
    required this.name,
    required this.instructions,
    required this.ingredients,
    required this.image,
    this.commentIds,
    this.likeIds,
    required this.preparingTimeInHours,
    required this.preparingTimeInMinutes,
    required this.preparingTimeInSeconds,
    required this.cookingTimeInHours,
    required this.cookingTimeInMinutes,
    required this.cookingTimeInSeconds,
    required this.categoryId,
  });

  // Factory constructor to create a Recipe object from JSON
  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['_id'],
      userId: json["userId"],
      cuisineId: json["cuisineId"],
      description: json['description'],
      name: json['name'],
      instructions: List<String>.from(json['instructions']),
      ingredients: List<String>.from(json['ingredients']),
      image: json['image'],
      commentIds: List<String>.from(json["commentIds"]),
      likeIds: List<String>.from(json["likeIds"]),
      preparingTimeInHours: json['preparingTimeInHours'] ?? 0,
      preparingTimeInMinutes: json['preparingTimeInMinutes'] ?? 0,
      preparingTimeInSeconds: json['preparingTimeInSeconds'] ?? 0,
      cookingTimeInHours: json['cookingTimeInHours'] ?? 0,
      cookingTimeInMinutes: json['cookingTimeInMinutes'] ?? 0,
      cookingTimeInSeconds: json['cookingTimeInSeconds'] ?? 0,
      categoryId: json["categoryId"],
    );
  }

  // Method to convert a Recipe object to JSON
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'cuisineId': cuisineId,
      'description': description,
      'name': name,
      "image": image,
      'instructions': instructions,
      'ingredients': ingredients,
      'preparingTimeInHours': preparingTimeInHours,
      'preparingTimeInMinutes': preparingTimeInMinutes,
      'preparingTimeInSeconds': preparingTimeInSeconds,
      'cookingTimeInHours': cookingTimeInHours,
      'cookingTimeInMinutes': cookingTimeInMinutes,
      'cookingTimeInSeconds': cookingTimeInSeconds,
      'categoryId': categoryId,
    };
  }
}
