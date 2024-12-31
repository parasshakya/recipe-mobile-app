import 'package:dio/dio.dart';
import 'package:recipe_flutter_app/config/config.dart';
import 'package:recipe_flutter_app/interceptors/app_interceptor.dart';

class CommentModel {
  late final Dio dio;

  CommentModel() {
    dio = Dio(BaseOptions(
      baseUrl: Config.localBaseUrl,
      connectTimeout: const Duration(seconds: 10), // 10 seconds
      receiveTimeout: const Duration(seconds: 15), // 15 seconds
    ));
    dio.interceptors.add(AppInterceptor(dio: dio));
  }
}
