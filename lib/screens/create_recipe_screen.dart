import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/models/category.dart';
import 'package:recipe_flutter_app/models/cuisine.dart';
import 'package:recipe_flutter_app/models/recipe.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';
import 'package:recipe_flutter_app/services/api_services.dart';
import 'package:recipe_flutter_app/utils.dart';

class CreateRecipeScreen extends StatefulWidget {
  @override
  _CreateRecipeScreenState createState() => _CreateRecipeScreenState();
}

class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final authProvider = AuthProvider();

  // Form field controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _preparingTimeHoursController =
      TextEditingController();
  final TextEditingController _preparingTimeMinutesController =
      TextEditingController();
  final TextEditingController _cookingTimeHoursController =
      TextEditingController();
  final TextEditingController _cookingTimeMinutesController =
      TextEditingController();
  final TextEditingController _cookingTimeSecondsController =
      TextEditingController();
  final TextEditingController _preparingTimeSecondsController =
      TextEditingController();

  String? _selectedCuisineId;
  String? _selectedCategoryId;
  String? _imagePath;

  List<String> ingredients = [""];
  List<String> instructions = [""];

  // Dummy data for cuisines and categories
  List<Cuisine> cuisines = [];
  List<Category> categories = [];

  @override
  void initState() {
    fetchData();
    super.initState();
  }

  fetchData() async {
    await fetchCuisines();
    await fetchCategories();
    setState(() {});
  }

  fetchCuisines() async {
    cuisines = await ApiService().fetchCuisines();
  }

  fetchCategories() async {
    categories = await ApiService().fetchCategories();
  }

  addIngredients() {
    ingredients.add("");
    setState(() {});
  }

  removeIngredient(int index) {
    ingredients.removeAt(index);
    setState(() {});
  }

  addInstructions() {
    instructions.add("");
    setState(() {});
  }

  removeInstruction(int index) {
    instructions.removeAt(index);
    setState(() {});
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final currentUser =
          Provider.of<AuthProvider>(context, listen: false).currentUser!;
      try {
        // Process the form data
        final recipe = Recipe(
            id: "",
            image: _imagePath!,
            userId: currentUser.id,
            cuisineId: _selectedCuisineId!,
            description: _descriptionController.text,
            name: _nameController.text,
            instructions: instructions,
            ingredients: ingredients,
            preparingTimeInHours: int.parse(_preparingTimeHoursController.text),
            preparingTimeInMinutes:
                int.parse(_preparingTimeSecondsController.text),
            preparingTimeInSeconds:
                int.parse(_preparingTimeSecondsController.text),
            cookingTimeInHours: int.parse(_cookingTimeHoursController.text),
            cookingTimeInMinutes: int.parse(_cookingTimeMinutesController.text),
            cookingTimeInSeconds: int.parse(_cookingTimeSecondsController.text),
            categoryId: _selectedCategoryId!);

        await ApiService().createRecipe(recipe);

        showSnackbar("Recipe created successfully", context);
      } catch (e) {
        showSnackbar(
            "Failed to create recipe, Please try again later.", context);
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _imagePath = pickedFile?.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Recipe Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter a recipe name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Enter a description' : null,
              ),
              ...ingredients.asMap().keys.map((index) {
                String ingredient = ingredients[index];
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: ingredient,
                        decoration: InputDecoration(
                            labelText: "Enter Ingredient ${index + 1}"),
                        onChanged: (value) {
                          setState(() {
                            ingredients[index] = value;
                          });
                        },
                        validator: (value) => value!.isEmpty
                            ? "Please enter ingredient ${index + 1}"
                            : null,
                      ),
                    ),
                    if (index > 0)
                      IconButton(
                          onPressed: () {
                            removeIngredient(index);
                          },
                          icon: Icon(Icons.delete))
                  ],
                );
              }),
              ElevatedButton(
                  onPressed: () {
                    addIngredients();
                  },
                  child: Text("Add ingredient")),
              ...instructions.asMap().keys.map((index) {
                String instruction = instructions[index];
                return Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: instruction,
                        onChanged: (value) {
                          setState(() {
                            instructions[index] = value;
                          });
                        },
                        decoration: InputDecoration(
                            labelText: 'Enter Instruction ${index + 1}'),
                        validator: (value) => value!.isEmpty
                            ? 'Enter instruction ${index + 1}'
                            : null,
                      ),
                    ),
                    if (index > 0)
                      IconButton(
                          onPressed: () {
                            removeInstruction(index);
                          },
                          icon: Icon(Icons.delete))
                  ],
                );
              }),
              ElevatedButton(
                  onPressed: () {
                    addInstructions();
                  },
                  child: Text("Add instruction")),
              DropdownButtonFormField<String>(
                value: _selectedCuisineId,
                decoration: InputDecoration(labelText: 'Cuisine'),
                items: cuisines
                    .map((cuisine) => DropdownMenuItem(
                        value: cuisine.id, child: Text(cuisine.name)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCuisineId = value;
                  });
                },
                validator: (value) => value == null ? 'Select a cuisine' : null,
              ),
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: InputDecoration(labelText: 'Category'),
                items: categories
                    .map((category) => DropdownMenuItem(
                        value: category.id, child: Text(category.name)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Select a category' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _preparingTimeHoursController,
                      decoration:
                          InputDecoration(labelText: 'Preparing Time (Hours)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _preparingTimeMinutesController,
                      decoration: InputDecoration(
                          labelText: 'Preparing Time (Minutes)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _preparingTimeSecondsController,
                      decoration: InputDecoration(
                          labelText: 'Preparing Time (Seconds)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cookingTimeHoursController,
                      decoration:
                          InputDecoration(labelText: 'Cooking Time (Hours)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cookingTimeMinutesController,
                      decoration:
                          InputDecoration(labelText: 'Cooking Time (Minutes)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cookingTimeSecondsController,
                      decoration:
                          InputDecoration(labelText: 'Cooking Time (Seconds)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (_imagePath != null)
                Image.file(
                  File(_imagePath!),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label:
                    Text(_imagePath == null ? 'Upload Image' : 'Change Image'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Create Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
