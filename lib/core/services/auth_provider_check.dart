import 'package:flutter/material.dart';

import '../../storage/secure_tokenstorage.dart';

class AuthProviderCheck with ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  AuthProviderCheck() {
    _checkLoggin(); // Kiểm tra trạng thái khi khởi tạo provider
  }

  Future<void> _checkLoggin() async {
    String? token = await SecureTokenStorage.getToken();
    _isLoggedIn = token != null;
    notifyListeners(); // Cập nhật giao diện sau khi kiểm tra token
  }

  Future<void> login(String token) async {
    // Lưu token sau khi đăng nhập
    await SecureTokenStorage.saveToken(token);
    _isLoggedIn = true;
    notifyListeners(); // Cập nhật giao diện sau khi lưu token
  }

  Future<void> logout() async {
    await SecureTokenStorage.deleteToken();
    _isLoggedIn = false;
    notifyListeners(); // Cập nhật giao diện sau khi xóa token
  }
}
