import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/config/config.dart';
import 'package:recipe_flutter_app/utils.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final secureStorage = const FlutterSecureStorage();

  AuthInterceptor({required this.dio});

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Retrieve the token from storage
    String? accessToken = await secureStorage.read(key: "accessToken");

    // Add headers if the token exists
    if (accessToken != null) {
      options.headers["Authorization"] = "Bearer $accessToken";
    }
    options.headers["Content-Type"] = "application/json";

    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Check if it's a network error
    if (err.type == DioExceptionType.unknown ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.connectionError) {
      // Handle no internet connection
      print("No internet connection");
      ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
        const SnackBar(
            content: Text(
                'No internet connection. Please check your connection and try again.')),
      );

      return; // Stop further error handling
    }

    // Check if the error is a 401 Unauthorized error
    if (err.response?.statusCode == 401) {
      // Refresh the token
      final newAccessTokenResponse = await refreshToken();

      if (newAccessTokenResponse != null &&
          newAccessTokenResponse.statusCode == 200) {
        // Update the token in storage and retry the request
        String newToken = newAccessTokenResponse.data["accessToken"];
        await secureStorage.write(key: "accessToken", value: newToken);

        // Retry the original request with the updated token
        handler.resolve(await _retry(err.requestOptions, newToken));
      } else {
        handler.next(err);
      }
      // Return to prevent the next interceptor in the chain from being executed
      return;
    }
  }

  Future<Response<dynamic>?> refreshToken() async {
    try {
      final dio = Dio();
      // Assume you have the refresh token saved
      String? refreshToken = await secureStorage.read(key: "refreshToken");

      // Call the refresh endpoint to get a new token
      var response = await dio.post(
        "${Config.baseUrl}/auth/refresh-token",
        options: Options(
          headers: {
            "Refresh-Token": refreshToken,
          },
        ),
      );

      // Return the response if successful
      return response;
    } on DioException catch (e) {
      // Handle the error (logging, etc.)
      print("Error refreshing token $e");
      print("DioException caught: ${e.message}");
      print("Request Options: ${e.requestOptions}");
      if (e.response != null) {
        print("Response data: ${e.response?.data}");
        print("Response status: ${e.response?.statusCode}");
        if (e.response?.statusCode == 401) {
          await Provider.of<AuthProvider>(navigatorKey.currentState!.context,
                  listen: false)
              .logout();
        }
      }

      return null;
    }
  }

  Future<Response<dynamic>> _retry(
      RequestOptions requestOptions, String newToken) async {
    // Add the new token to the headers and retry the request
    final options = Options(
      method: requestOptions.method,
      headers: {
        "Authorization": "Bearer $newToken",
      },
    );
    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
