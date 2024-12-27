import 'package:flutter/cupertino.dart';

import '../../../models/user_model.dart';
import '../../../storage/secure_tokenstorage.dart';
import '../auth_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  Future<void> refreshUser() async {
    try {
      final authService = AuthService();
      final updatedUser = await authService.fetchUser();
      _user = updatedUser;
      await SecureTokenStorage.saveUser(updatedUser);
      notifyListeners();
    } catch (e) {
      print('Lỗi khi refresh user: $e');
    }
  }

  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
}
