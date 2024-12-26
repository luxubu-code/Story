import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class SecureTokenStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> deleteToken() async {
    print('đã xóa token');
    await _storage.delete(key: 'auth_token');
  }

  /// Saves user data using SharedPreferences
  static Future<void> saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String userJson = jsonEncode(user.toJson());
      await prefs.setString('user_data', userJson);
      print('User data saved successfully');
    } catch (e) {
      print('Error saving user data: $e');
    }
  }

  /// Retrieves stored user data
  static Future<UserModel?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userJson = prefs.getString('user_data');

      if (userJson == null) return null;

      Map<String, dynamic> userMap = jsonDecode(userJson);
      return UserModel.fromJson(userMap);
    } catch (e) {
      print('Error retrieving user data: $e');
      return null;
    }
  }

  /// Deletes stored user data
  static Future<void> deleteUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_data');
      print('User data deleted successfully');
    } catch (e) {
      print('Error deleting user data: $e');
    }
  }
}
