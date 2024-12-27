import 'package:dio/dio.dart';
import 'package:recipe_flutter_app/config/config.dart';
import 'package:recipe_flutter_app/interceptors/app_interceptor.dart';
import 'package:recipe_flutter_app/schemas/cuisine.dart';

class CuisineModel {
  late final Dio dio;

  CuisineModel() {
    dio = Dio(BaseOptions(
      baseUrl: Config.localBaseUrl,
      connectTimeout: const Duration(seconds: 10), // 10 seconds
      receiveTimeout: const Duration(seconds: 15), // 15 seconds
    ));
    dio.interceptors.add(AppInterceptor(dio: dio));
  }

  Future<List<Cuisine>> fetchCuisines() async {
    final response = await dio.get("/cuisines");
    final cuisines = response.data['data'] as List;
    return cuisines.map((e) => Cuisine.fromJson(e)).toList();
  }

  Future<Cuisine> fetchCuisine(String cuisineId) async {
    final response = await dio.get("/cuisines/$cuisineId");

    final cuisineData = response.data["data"];
    return Cuisine.fromJson(cuisineData);
  }
}
