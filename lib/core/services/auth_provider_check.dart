import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../storage/secure_tokenstorage.dart'; // Add this import

class AuthProviderCheck with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoggedIn = false;

  AuthProviderCheck() {
    _initializeUserState();
  }

  // Initialize user state from secure storage
  Future<void> _initializeUserState() async {
    final storedUser = await SecureTokenStorage.getUser();
    final token = await SecureTokenStorage.getToken();

    if (storedUser != null && token != null) {
      updateUserState(user: storedUser);
    }
  }

  UserModel? get currentUser => _currentUser;

  bool get isLoggedIn => _isLoggedIn;

  // Comprehensive user state update method
  void updateUserState({UserModel? user}) {
    _currentUser = user;
    _isLoggedIn = user != null;

    // Sync with secure storage
    if (user != null) {
      SecureTokenStorage.saveUser(user);
    }

    notifyListeners();
    print("User state updated: ${_currentUser?.name}, "
        "avatar ${_currentUser?.avatar_url}, "
        "Logged in: $_isLoggedIn");
  }

  // Enhanced login method
  void login(String token) async {
    _isLoggedIn = true;

    // Attempt to fetch and update user data
    try {
      final user = await SecureTokenStorage.getUser();
      if (user != null) {
        _currentUser = user;
      }
      print(await SecureTokenStorage.getToken());
    } catch (e) {
      print('Error fetching user during login: $e');
    }

    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _currentUser = null;

    SecureTokenStorage.deleteToken();
    SecureTokenStorage.deleteUser();
    print('Deleted toke and user');

    notifyListeners();
  }
}
