import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/models/cusine_model.dart';
import 'package:recipe_flutter_app/schemas/cuisine.dart';

class CuisineViewModel extends ChangeNotifier {
  final CuisineModel cuisineModel;

  List<Cuisine> _cuisines = [];

  CuisineViewModel({required this.cuisineModel});

  List<Cuisine> get cuisines => _cuisines;

  bool cusinesLoading = false;
  bool cuisineByIdLoading = false;
  bool cuisineByIdError = false;

  String? cuisinesError;

  Cuisine? _cuisineById;

  get cuisineById => _cuisineById;

  loadAllCuisines() async {
    try {
      cusinesLoading = true;
      _cuisines = await cuisineModel.fetchCuisines();
    } catch (e) {
      cuisinesError = "Something went wrong";
    } finally {
      cusinesLoading = false;
    }
    notifyListeners();
  }

  loadCuisine(String cuisineId) async {
    cuisineByIdLoading = true;
    cuisineByIdError = false;
    notifyListeners();
    try {
      _cuisineById = await cuisineModel.fetchCuisine(cuisineId);
    } catch (e) {
      cuisineByIdError = true;
    } finally {
      cuisineByIdLoading = false;
      notifyListeners();
    }
  }
}
