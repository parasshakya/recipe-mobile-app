// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:recipe_flutter_app/models/recipe.dart';
// import 'package:recipe_flutter_app/providers/recipe_provider.dart';
// import 'package:recipe_flutter_app/services/api_services.dart';

// class CreateRecipeScreen extends StatefulWidget {
//   @override
//   _CreateRecipeScreenState createState() => _CreateRecipeScreenState();
// }

// class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
//   final _formKey = GlobalKey<FormState>();
//   String? name, description, imageUrl;
//   List<String> ingredients = [];
//   List<String> instructions = [];
//   String? cuisineId, categoryId;
//   int prepHours = 0, prepMinutes = 0, prepSeconds = 0;
//   int cookHours = 0, cookMinutes = 0, cookSeconds = 0;

//   TextEditingController ingredientController = TextEditingController();
//   TextEditingController instructionController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     final recipeProvider = Provider.of<RecipeProvider>(context, listen: false);
//     final cuisines = recipeProvider.cuisines; // Assuming you have a list of cuisines
//     final categories = recipeProvider.categories; // Assuming you have a list of categories

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Create Recipe"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 decoration: InputDecoration(labelText: "Recipe Name"),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a recipe name';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) => name = value,
//               ),
//               TextFormField(
//                 decoration: InputDecoration(labelText: "Description"),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a description';
//                   }
//                   return null;
//                 },
//                 onSaved: (value) => description = value,
//               ),
//               DropdownButtonFormField(
//                 decoration: InputDecoration(labelText: "Cuisine"),
//                 value: cuisineId,
//                 items: cuisines.map((cuisine) {
//                   return DropdownMenuItem(
//                     value: cuisine.id, // Assuming cuisine.id exists
//                     child: Text(cuisine.name), // Assuming cuisine.name exists
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     cuisineId = value as String?;
//                   });
//                 },
//                 validator: (value) {
//                   if (value == null) {
//                     return 'Please select a cuisine';
//                   }
//                   return null;
//                 },
//               ),
//               DropdownButtonFormField(
//                 decoration: InputDecoration(labelText: "Category"),
//                 value: categoryId,
//                 items: categories.map((category) {
//                   return DropdownMenuItem(
//                     value: category.id, // Assuming category.id exists
//                     child: Text(category.name), // Assuming category.name exists
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     categoryId = value as String?;
//                   });
//                 },
//                 validator: (value) {
//                   if (value == null) {
//                     return 'Please select a category';
//                   }
//                   return null;
//                 },
//               ),
//               // Ingredients
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Ingredients"),
//                   TextFormField(
//                     controller: ingredientController,
//                     decoration: InputDecoration(
//                         labelText: "Add an ingredient", suffixIcon: IconButton(
//                         icon: Icon(Icons.add),
//                         onPressed: () {
//                           setState(() {
//                             if (ingredientController.text.isNotEmpty) {
//                               ingredients.add(ingredientController.text);
//                               ingredientController.clear();
//                             }
//                           });
//                         },
//                       )),
//                   ),
//                   Wrap(
//                     children: ingredients
//                         .map((ingredient) => Chip(
//                               label: Text(ingredient),
//                               onDeleted: () {
//                                 setState(() {
//                                   ingredients.remove(ingredient);
//                                 });
//                               },
//                             ))
//                         .toList(),
//                   ),
//                 ],
//               ),
//               // Instructions
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text("Instructions"),
//                   TextFormField(
//                     controller: instructionController,
//                     decoration: InputDecoration(
//                         labelText: "Add an instruction", suffixIcon: IconButton(
//                         icon: Icon(Icons.add),
//                         onPressed: () {
//                           setState(() {
//                             if (instructionController.text.isNotEmpty) {
//                               instructions.add(instructionController.text);
//                               instructionController.clear();
//                             }
//                           });
//                         },
//                       )),
//                   ),
//                   Wrap(
//                     children: instructions
//                         .map((instruction) => Chip(
//                               label: Text(instruction),
//                               onDeleted: () {
//                                 setState(() {
//                                   instructions.remove(instruction);
//                                 });
//                               },
//                             ))
//                         .toList(),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),
//               // Preparation Time
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       decoration: InputDecoration(labelText: "Prep Hours"),
//                       keyboardType: TextInputType.number,
//                       onSaved: (value) => prepHours = int.parse(value ?? '0'),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: TextFormField(
//                       decoration: InputDecoration(labelText: "Prep Minutes"),
//                       keyboardType: TextInputType.number,
//                       onSaved: (value) => prepMinutes = int.parse(value ?? '0'),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: TextFormField(
//                       decoration: InputDecoration(labelText: "Prep Seconds"),
//                       keyboardType: TextInputType.number,
//                       onSaved: (value) => prepSeconds = int.parse(value ?? '0'),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),
//               // Cooking Time
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       decoration: InputDecoration(labelText: "Cook Hours"),
//                       keyboardType: TextInputType.number,
//                       onSaved: (value) => cookHours = int.parse(value ?? '0'),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: TextFormField(
//                       decoration: InputDecoration(labelText: "Cook Minutes"),
//                       keyboardType: TextInputType.number,
//                       onSaved: (value) => cookMinutes = int.parse(value ?? '0'),
//                     ),
//                   ),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: TextFormField(
//                       decoration: InputDecoration(labelText: "Cook Seconds"),
//                       keyboardType: TextInputType.number,
//                       onSaved: (value) => cookSeconds = int.parse(value ?? '0'),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     _formKey.currentState!.save();

//                     Recipe recipe = Recipe(
//                       name: name!,
//                       description: description!,
//                       cuisine: cuisineId!,
//                       category: categoryId!,
//                       ingredients: ingredients,
//                       instructions: instructions,
//                       preparingTimeInHours: prepHours,
//                       preparingTimeInMinutes: prepMinutes,
//                       preparingTimeInSeconds: prepSeconds,
//                       cookingTimeInHours: cookHours,
//                       cookingTimeInMinutes: cookMinutes,
//                       cookingTimeInSeconds: cookSeconds,
//                       image: imageUrl ?? "",
//                     );

//                     // Send the recipe to the backend
//                     ApiService().createRecipe(recipe);
//                   }
//                 },
//                 child: Text("Submit"),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
