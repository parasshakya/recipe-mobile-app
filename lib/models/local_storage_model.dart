import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LocalStorageModel {
  final _secureStorage = const FlutterSecureStorage();

  Future<void> clearUserData() async {
    _secureStorage.delete(key: "userData");
  }

  Future<void> clearTokens() async {
    _secureStorage.delete(key: "accessToken");
    _secureStorage.delete(key: "refreshToken");
    _secureStorage.delete(key: "fcmToken");
  }

  Future<String> getUserData() async {
    final userDataString = await _secureStorage.read(key: "userData");
    return userDataString!;
  }

  Future<void> storeCredentials(
      String accessToken, String refreshToken, String userDataString) async {
    await _secureStorage.write(key: "accessToken", value: accessToken);
    await _secureStorage.write(key: "refreshToken", value: refreshToken);
    await _secureStorage.write(key: "userData", value: userDataString);
  }
}
