import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:recipe_flutter_app/config/config.dart';
import 'package:recipe_flutter_app/utils.dart';
import 'package:recipe_flutter_app/main.dart';
import 'package:recipe_flutter_app/providers/auth_provider.dart';

class AppInterceptor extends Interceptor {
  final Dio dio;
  final secureStorage = const FlutterSecureStorage();

  AppInterceptor({required this.dio});

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Retrieve the token from storage
    String? accessToken = await secureStorage.read(key: "accessToken");

    print("ACCESS TOKEN IS $accessToken");

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
      final newAccessTokenResponse = await refreshAccessToken();
      print("NEW ACCESS TOKEN RESPONSE IS $newAccessTokenResponse");

      if (newAccessTokenResponse != null &&
          newAccessTokenResponse.statusCode == 200) {
        // Update the token in storage and retry the request
        String newToken = newAccessTokenResponse.data["accessToken"];
        await secureStorage.write(key: "accessToken", value: newToken);
        print("NEW ACCESS TOKEN RECEIVED AFTER REFRESHING $newToken");

        // Retry the original request with the updated token
        handler.resolve(await _retry(err.requestOptions, newToken));
      } else {
        handler.next(err);
      }
      // Return to prevent the next interceptor in the chain from being executed
      return;
    }

    //handle other error status codes
    String errorMessage;
    switch (err.response?.statusCode) {
      case 400:
        errorMessage = err.response?.data["message"] ??
            "Invalid request. Please check your input.";
        break;

      case 403:
        errorMessage = err.response?.data["message"] ??
            "You do not have permission to perform this action.";
        break;
      case 404:
        errorMessage = err.response?.data["message"] ??
            "The requested resource was not found.";
        break;
      case 500:
        errorMessage = err.response?.data["message"] ??
            "An unexpected error occurred on the server.";
        break;
      default:
        errorMessage =
            "An unexpected error occurred. Please try again."; // Fallback for unknown errors
        break;
    }

    // Show the snackbar with the appropriate error message
    showSnackbar(errorMessage, navigatorKey.currentState!.context);
    return; // Stop further error handling
  }

  Future<Response<dynamic>?> refreshAccessToken() async {
    try {
      final dio = Dio();
      final authProvider = Provider.of<AuthProvider>(
          navigatorKey.currentState!.context,
          listen: false);
      // Assume you have the refresh token saved
      String? refreshToken = await secureStorage.read(key: "refreshToken");

      print("REFRESH TOKEN SENT FROM APP: $refreshToken");

      // Call the refresh endpoint to get a new token
      var response =
          await dio.post("${Config.baseUrl}/auth/refresh-token", data: {
        "refreshToken": refreshToken,
      });

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
    print("RETRYING WITH NEW ACCESS TOKEN $newToken");
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
