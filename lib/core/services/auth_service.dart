import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:story/core/services/provider/user_provider.dart';

import '../../main.dart';
import '../../models/user_model.dart';
import '../../routes/api_endpoints.dart';
import '../../storage/secure_tokenstorage.dart';
import '../utils/Snackbar.dart';
import 'api_service.dart';
import 'provider/auth_provider_check.dart';

class AuthService {
  // final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth auth = FirebaseAuth.instance;

// Initialize GoogleSignIn with specific configuration
  final GoogleSignIn googleSignIn = GoogleSignIn(
    forceCodeForRefreshToken: true,
    signInOption: SignInOption.standard,
  );

  Future<Map<String, dynamic>?> signInWithGoogle(BuildContext context) async {
    await SecureTokenStorage.deleteUser();
    await SecureTokenStorage.deleteToken();
    try {
      // Sign out before signing in to ensure fresh account selection
      await googleSignIn.signOut();

      // Attempt to sign in and show account picker
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        print("Người dùng đã hủy đăng nhập");
        return null;
      }

      return await _handleSignIn(googleUser, context);
    } catch (e) {
      print('Lỗi chi tiết: $e');
      Snack_Bar('Lỗi khi đăng nhập với Google: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> _handleSignIn(
      GoogleSignInAccount googleUser, BuildContext context) async {
    try {
      // Get authentication details from Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Debug logging for token verification
      print('Google ID Token: ${googleAuth.idToken?.substring(0, 20)}...');

      // Make API request to your backend
      final data = await ApiService.request(
        url: ApiEndpoints.postGoogle,
        method: "POST",
        body: {'idToken': googleAuth.idToken},
        isJson: false,
      );

      // Validate API response
      if (data == null) {
        throw Exception('Phản hồi API trả về null');
      }

      print('Cấu trúc dữ liệu nhận được: ${data.keys.toList()}');

      // Validate required fields in response
      if (!data.containsKey('access_token')) {
        throw Exception('Thiếu trường access_token trong phản hồi');
      }
      if (!data.containsKey('data')) {
        throw Exception('Thiếu thông tin user trong phản hồi');
      }

      // Store authentication token securely
      await SecureTokenStorage.saveToken(data['access_token']);

      // Update authentication state in provider
      final authProvider =
          Provider.of<AuthProviderCheck>(context, listen: false);
      authProvider.login(data['access_token']);

      // Save user data
      UserModel user = UserModel.fromJson(data['data']);
      await SecureTokenStorage.saveUser(user);

      Snack_Bar('Đăng nhập thành công');
      return data;
    } catch (e) {
      print('Chi tiết lỗi trong _handleSignIn: $e');
      Snack_Bar('Đăng nhập Google thất bại');
      throw Exception('Đăng nhập Google thất bại: $e');
    }
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    try {
      // Clear existing credentials
      await SecureTokenStorage.deleteUser();
      await SecureTokenStorage.deleteToken();

      // Make the API request
      final response = await ApiService.request(
        url: ApiEndpoints.login,
        method: "POST",
        body: {'email': email, 'password': password},
        isJson: false,
      );

      // Validate response
      if (response == null) {
        throw Exception('Dữ liệu API trả về null');
      }

      // Validate access token
      if (!response.containsKey('access_token') ||
          response['access_token'] == null) {
        throw Exception('Thiếu hoặc null access_token trong phản hồi');
      }

      // Extract user data from the 'data' field
      if (!response.containsKey('data') || response['data'] == null) {
        throw Exception('Thiếu hoặc null data trong phản hồi');
      }

      // Save token
      final token = response['access_token'];
      await SecureTokenStorage.saveToken(token);

      // Create and save user model
      UserModel user = UserModel.fromJson(response['data']);
      await SecureTokenStorage.saveUser(user);

      // Update auth state
      final authProvider =
          Provider.of<AuthProviderCheck>(context, listen: false);
      authProvider.login(token);

      Snack_Bar('Đăng nhập thành công');
    } catch (e) {
      print('Lỗi khi đăng nhập: $e');
      Snack_Bar('Đăng nhập thất bại: ${e.toString()}');
    }
  }

  Future<void> register(
      String email, String password, String passwordConfirmation) async {
    try {
      final data = await ApiService.request(
        url: ApiEndpoints.register,
        method: "POST",
        body: {
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation
        },
        isJson: false,
      );

      if (data['status'] == 'success') {
        Snack_Bar('Đăng ký thành công');
      } else {
        Snack_Bar('Đăng ký thất bại: ${data['message']}');
      }
    } catch (e) {
      print('Lỗi khi đăng ký: $e');
      Snack_Bar('Đăng ký thất bại: $e');
    }
  }

  static Future<void> sendFcm(String fcmToken) async {
    try {
      final token = await SecureTokenStorage.getToken();
      if (token == null || token.isEmpty) {
        print('No token available, skipping FCM send');
        return;
      }

      await ApiService.request(
        url: ApiEndpoints.sendFcm,
        method: "POST",
        headers: {'Authorization': 'Bearer $token'},
        body: {'token': fcmToken},
      );

      print('FCM Token sent successfully');
    } catch (e) {
      print('Error sending FCM Token: $e');
    }
  }

  static Future<void> logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProviderCheck>(context, listen: false);
    await SecureTokenStorage.deleteUser();
    await SecureTokenStorage.deleteToken();
    authProvider.logout();

    Snack_Bar('Đã đăng xuất');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(initialIndex: 4),
      ),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> updateUserAccount({
    required String token,
    required String name,
    required String dateOfBirth,
    String? imagePath,
    required BuildContext context,
  }) async {
    try {
      // First, prepare the request body
      final body = {
        'name': name,
        'date_of_birth': dateOfBirth,
      };

      // Make the API request to update the profile
      final data = await ApiService.request(
        url: ApiEndpoints.updateProfile,
        method: "MULTIPART",
        token: token,
        body: body,
        imagePath: imagePath,
      );
      // Kiểm tra và xử lý dữ liệu trả về
      if (data == null || !data.containsKey('data')) {
        throw Exception('Phản hồi không hợp lệ từ server');
      }
      final updatedUserData = data['data'];
      UserModel updatedUser = UserModel.fromJson(updatedUserData);

      // Cập nhật dữ liệu trong UserProvider
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      print('Cập nhật dữ liệu trong UserProvider');
      userProvider.setUser(updatedUser);
      await SecureTokenStorage.saveUser(updatedUser);
    } catch (e) {
      Snack_Bar('Lỗi khi cập nhật thông tin: $e');
      print('Lỗi khi cập nhật tài khoản: $e');
    }
  }

  Future<UserModel> fetchUser() async {
    try {
      final token = await SecureTokenStorage.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('No token available');
      }

      final data = await ApiService.request(
        url: ApiEndpoints.getUser,
        method: "GET",
        headers: {'Authorization': 'Bearer $token'},
      );

      return UserModel.fromJson(data['data']);
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
      throw Exception('Failed to fetch user: $e');
    }
  }
}
