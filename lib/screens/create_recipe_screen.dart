// import 'package:flutter/material.dart';
// import 'package:recipe_flutter_app/models/recipe.dart';

// class CreateRecipeScreen extends StatefulWidget {
//   @override
//   _CreateRecipeScreenState createState() => _CreateRecipeScreenState();
// }

// class _CreateRecipeScreenState extends State<CreateRecipeScreen> {
//   final _formKey = GlobalKey<FormState>();

//   // Form field controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _ingredientsController = TextEditingController();
//   final TextEditingController _instructionsController = TextEditingController();
//   final TextEditingController _preparingTimeHoursController =
//       TextEditingController();
//   final TextEditingController _preparingTimeMinutesController =
//       TextEditingController();
//   final TextEditingController _cookingTimeHoursController =
//       TextEditingController();
//   final TextEditingController _cookingTimeMinutesController =
//       TextEditingController();
//   final TextEditingController _cookingTimeSecondsController =
//       TextEditingController();
//   final TextEditingController _preparingTimeSecondsController =
//       TextEditingController();

//   String? _selectedCuisine;
//   String? _selectedCategory;
//   String? _imagePath;

//   // Dummy data for cuisines and categories
//   final List<String> cuisines = ['Indian', 'Italian', 'Chinese', 'Mexican'];
//   final List<String> categories = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];

//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       // Process the form data
//       final recipe = Recipe(
//           id: "",
//           user: ,
//           cuisine: cuisine,
//           description: description,
//           name: name,
//           instructions: instructions,
//           ingredients: ingredients,
//           image: image,
//           comments: comments,
//           likes: likes,
//           preparingTimeInHours: preparingTimeInHours,
//           preparingTimeInMinutes: preparingTimeInMinutes,
//           preparingTimeInSeconds: preparingTimeInSeconds,
//           cookingTimeInHours: cookingTimeInHours,
//           cookingTimeInMinutes: cookingTimeInMinutes,
//           cookingTimeInSeconds: cookingTimeInSeconds,
//           category: category);
//       // Send data to the backend
//       // Use Dio or Http to send the recipeData to the server
//     }
//   }

//   Future<void> _pickImage() async {
//     // Implement image picker logic
//     // Example: Use the image_picker package to select an image
//     // final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//     // setState(() {
//     //   _imagePath = pickedFile?.path;
//     // });
//     print('Image picker not implemented yet');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Create Recipe'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(labelText: 'Recipe Name'),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter a recipe name' : null,
//               ),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: InputDecoration(labelText: 'Description'),
//                 maxLines: 3,
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter a description' : null,
//               ),
//               TextFormField(
//                 controller: _ingredientsController,
//                 decoration:
//                     InputDecoration(labelText: 'Ingredients (comma-separated)'),
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter ingredients' : null,
//               ),
//               TextFormField(
//                 controller: _instructionsController,
//                 decoration: InputDecoration(
//                     labelText: 'Instructions (newline-separated)'),
//                 maxLines: 5,
//                 validator: (value) =>
//                     value!.isEmpty ? 'Enter instructions' : null,
//               ),
//               DropdownButtonFormField<String>(
//                 value: _selectedCuisine,
//                 decoration: InputDecoration(labelText: 'Cuisine'),
//                 items: cuisines
//                     .map((cuisine) =>
//                         DropdownMenuItem(value: cuisine, child: Text(cuisine)))
//                     .toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedCuisine = value;
//                   });
//                 },
//                 validator: (value) => value == null ? 'Select a cuisine' : null,
//               ),
//               DropdownButtonFormField<String>(
//                 value: _selectedCategory,
//                 decoration: InputDecoration(labelText: 'Category'),
//                 items: categories
//                     .map((category) => DropdownMenuItem(
//                         value: category, child: Text(category)))
//                     .toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedCategory = value;
//                   });
//                 },
//                 validator: (value) =>
//                     value == null ? 'Select a category' : null,
//               ),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _preparingTimeHoursController,
//                       decoration:
//                           InputDecoration(labelText: 'Preparing Time (Hours)'),
//                       keyboardType: TextInputType.number,
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _preparingTimeMinutesController,
//                       decoration: InputDecoration(
//                           labelText: 'Preparing Time (Minutes)'),
//                       keyboardType: TextInputType.number,
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _preparingTimeSecondsController,
//                       decoration: InputDecoration(
//                           labelText: 'Preparing Time (Seconds)'),
//                       keyboardType: TextInputType.number,
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: _cookingTimeHoursController,
//                       decoration:
//                           InputDecoration(labelText: 'Cooking Time (Hours)'),
//                       keyboardType: TextInputType.number,
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _cookingTimeMinutesController,
//                       decoration:
//                           InputDecoration(labelText: 'Cooking Time (Minutes)'),
//                       keyboardType: TextInputType.number,
//                     ),
//                   ),
//                   SizedBox(width: 16),
//                   Expanded(
//                     child: TextFormField(
//                       controller: _cookingTimeSecondsController,
//                       decoration:
//                           InputDecoration(labelText: 'Cooking Time (Seconds)'),
//                       keyboardType: TextInputType.number,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 16),
//               ElevatedButton.icon(
//                 onPressed: _pickImage,
//                 icon: Icon(Icons.image),
//                 label:
//                     Text(_imagePath == null ? 'Upload Image' : 'Change Image'),
//               ),
//               SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: _submitForm,
//                 child: Text('Create Recipe'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
