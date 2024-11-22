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

  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    print('đã lưu userdata');
    String Userjson = jsonEncode(user.toJson());
    print(Userjson);
    await prefs.setString('user_data', Userjson);
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    print('đã lấy userdata');
    String? userJson = prefs.getString('user_data');
    if (userJson == null) {
      return null;
    }
    Map<String, dynamic> user = jsonDecode(userJson);
    return UserModel.fromJson(user);
  }

  static Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    print('đã xóa userdata');
    await prefs.remove('user_data');
  }
}
