import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';

class SecureTokenStorage {
  static const _storage = FlutterSecureStorage();

  // Token Management
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: 'auth_token', value: token);
      print('Token saved successfully');
    } catch (e) {
      print('Error saving token: $e');
    }
  }

  static Future<String?> getToken() async {
    try {
      return await _storage.read(key: 'auth_token');
    } catch (e) {
      print('Error retrieving token: $e');
      return null;
    }
  }

  static Future<void> deleteToken() async {
    try {
      await _storage.delete(key: 'auth_token');
      print('Token deleted successfully');
    } catch (e) {
      print('Error deleting token: $e');
    }
  }

  // User Data Management
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
