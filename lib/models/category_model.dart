import 'package:dio/dio.dart';
import 'package:recipe_flutter_app/config/config.dart';
import 'package:recipe_flutter_app/interceptors/app_interceptor.dart';
import 'package:recipe_flutter_app/schemas/category.dart';

class CategoryModel {
  late final Dio dio;

  CategoryModel() {
    dio = Dio(BaseOptions(
      baseUrl: Config.localBaseUrl,
      connectTimeout: const Duration(seconds: 10), // 10 seconds
      receiveTimeout: const Duration(seconds: 15), // 15 seconds
    ));
    dio.interceptors.add(AppInterceptor(dio: dio));
  }

  Future<List<Category>> fetchCategories() async {
    final response = await dio.get("/categories");
    final categories = response.data['data'] as List;
    return categories.map((e) => Category.fromJson(e)).toList();
  }

  Future<Category> fetchCategory(String categoryId) async {
    final response = await dio.get("/categories/${categoryId}");
    final categoryJSON = response.data["data"];
    return Category.fromJson(categoryJSON);
  }
}
