import 'package:flutter/material.dart';
import 'package:recipe_flutter_app/models/category_model.dart';
import 'package:recipe_flutter_app/schemas/category.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryModel categoryModel;

  List<Category> _categories = [];

  List<Category> get categories => _categories;

  bool categoriesLoading = false;

  String? categoriesError;

  Category? _categoryById;

  Category? get categoryById => _categoryById;

  bool categoryLoading = false;

  bool categoryError = false;

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
      categoryError = false;
      notifyListeners();
      _categoryById = await categoryModel.fetchCategory(categoryId);
    } catch (e) {
      categoryError = true;
    } finally {
      categoryLoading = false;
      notifyListeners();
    }
  }
}
