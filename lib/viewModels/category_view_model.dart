import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/models/category_model.dart';
import 'package:recipe_flutter_app/schemas/category.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryModel categoryModel;

  List<Category> _categories = [];

  List<Category> get categories => _categories;

  bool categoriesLoading = false;

  String? categoriesError;

  Category? _category;

  bool categoryLoading = false;

  String? categoryError;

  CategoryViewModel({required this.categoryModel});

  loadAllCategories() async {
    try {
      categoriesLoading = true;
      notifyListeners();
      _categories = await categoryModel.fetchCategories();
    } catch (e) {
      categoriesError = "Something went wrong";
    } finally {
      categoriesLoading = false;
      notifyListeners();
    }
  }

  loadCategory(String categoryId) async {
    try {
      categoryLoading = true;
      notifyListeners();
      _category = await categoryModel.fetchCategory(categoryId);
    } catch (e) {
      categoryError = "Something went wrong";
    } finally {
      categoryLoading = false;
      notifyListeners();
    }
  }
}
