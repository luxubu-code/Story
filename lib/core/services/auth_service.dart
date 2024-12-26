import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../main.dart';
import '../../models/user_model.dart';
import '../../routes/api_endpoints.dart';
import '../../storage/secure_tokenstorage.dart';
import '../utils/Snackbar.dart';
import 'auth_provider_check.dart';
import 'error_handling_service.dart';

class AuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> signInWithGoogle(BuildContext context) async {
    return await ErrorHandler.handleError(
      context: context,
      operation: () async {
        // Đăng xuất tài khoản Google hiện tại trước khi đăng nhập mới
        await _googleSignIn.signOut();

        // Thực hiện đăng nhập mới
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        if (googleUser == null) {
          print("Người dùng hủy đăng nhập");
          return null;
        }
        return await _handleSignIn(googleUser, context);
      },
      customMessage: 'Đăng nhập Google không thành công',
    );
  }

  // Xử lý token sau khi đăng nhập với Google
  Future<Map<String, dynamic>> _handleSignIn(
      GoogleSignInAccount googleUser, BuildContext context) async {
    return await ErrorHandler.handleError(
      context: context,
      operation: () async {
        final googleAuth = await googleUser.authentication;
        final idToken = googleAuth.idToken;

        final response = await http.post(
          Uri.parse(ApiEndpoints.postGoogle),
          body: {'idToken': idToken},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final token = data['access_token'];
          final user = data['user'];

          if (token != null && user != null) {
            await SecureTokenStorage.saveToken(token);
            await SecureTokenStorage.saveUser(UserModel.fromJson(data['user']));

            final authProvider =
                Provider.of<AuthProviderCheck>(context, listen: false);
            authProvider.login(token);
            print('Đăng nhập thành công');
            return data;
          } else {
            throw Exception('Không tìm thấy token trong phản hồi');
          }
        } else {
          throw Exception('Đăng nhập thất bại: ${response.statusCode}');
        }
      },
      customMessage: 'Xác thực Google không thành công',
    );
  }

  // Đăng nhập với email và mật khẩu
  Future<void> login(
      String email, String password, BuildContext context) async {
    await ErrorHandler.handleError(
      context: context,
      operation: () async {
        final response = await http.post(
          Uri.parse(ApiEndpoints.login),
          headers: _headers(),
          body: {'email': email, 'password': password},
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final token = data['access_token'];

          await SecureTokenStorage.saveToken(token);
          await SecureTokenStorage.saveUser(UserModel.fromJson(data['user']));
          final authProvider =
              Provider.of<AuthProviderCheck>(context, listen: false);
          authProvider.login(token);
          print('Đăng nhập thành công');
        } else {
          throw Exception('Đăng nhập thất bại: ${response.statusCode}');
        }
      },
      customMessage: 'Đăng nhập không thành công',
    );
  }

  // Đăng ký tài khoản mới
  Future<void> register(BuildContext context, String email, String password,
      String confirmPassword) async {
    await ErrorHandler.handleError(
      context: context,
      operation: () async {
        final response = await http.post(
          Uri.parse(ApiEndpoints.register),
          headers: _headers(),
          body: {
            'email': email,
            'password': password,
            'password_confirmation': confirmPassword,
          },
        );

        if (response.statusCode == 200) {
          print('Đăng ký thành công');
          Snack_Bar('Đăng ký thành công');
        } else {
          throw Exception('Đăng ký thất bại: ${response.statusCode}');
        }
      },
      customMessage: 'Đăng ký không thành công',
    );
  }

  // Cập nhật thông tin người dùng
  Future<void> updateUserAccount({
    required String token,
    required String name,
    required String dateOfBirth,
    String? imagePath,
    required BuildContext context,
  }) async {
    await ErrorHandler.handleError(
      context: context,
      operation: () async {
        final request =
            http.MultipartRequest('POST', Uri.parse(ApiEndpoints.updateProfile))
              ..headers['Authorization'] = 'Bearer $token'
              ..fields['name'] = name
              ..fields['date_of_birth'] = dateOfBirth;

        if (imagePath != null) {
          request.files
              .add(await http.MultipartFile.fromPath('image', imagePath));
        }

        final response = await request.send();
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);

        if (response.statusCode == 200) {
          // Lấy thông tin người dùng mới sau khi cập nhật
          UserModel updatedUser = UserModel.fromJson(data['data']);
          final authProvider =
              Provider.of<AuthProviderCheck>(context, listen: false);
          authProvider.updateUserState(user: updatedUser);
          await SecureTokenStorage.saveUser(updatedUser);
          Snack_Bar('Cập nhật thành công');
          print('Cập nhật thành công: ${data['message']}');

          return true;
        } else {
          throw Exception('Cập nhật thất bại: ${data['message']}');
        }
      },
      customMessage: 'Cập nhật thông tin không thành công',
    );
  }

  // Lấy dữ liệu người dùng
  Future<UserModel> fetchUser(
    BuildContext context,
  ) async {
    final token = await SecureTokenStorage.getToken();
    return await ErrorHandler.handleError(
      context: context,
      operation: () async {
        final response = await http.get(
          Uri.parse(ApiEndpoints.getUser),
          headers: _authHeaders(token),
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          return UserModel.fromJson(jsonResponse['data']);
        } else {
          throw Exception('Không thể tải dữ liệu người dùng');
        }
      },
      customMessage: 'Không thể tải thông tin người dùng',
    );
  }

  // Gửi Token FCM với retry logic
  static Future<void> sendFcm(String fcmToken) async {
    final token = await SecureTokenStorage.getToken();
    int retryCount = 3;

    await ErrorHandler.handleError(
      operation: () async {
        while (retryCount > 0) {
          try {
            final response = await http.post(
              Uri.parse(ApiEndpoints.sendFcm),
              headers: _authHeaders(token),
              body: jsonEncode({'token': fcmToken}),
            );

            if (response.statusCode == 200) {
              print('Gửi FCM token thành công');
              return;
            }
            throw Exception('Gửi FCM thất bại: ${response.statusCode}');
          } catch (e) {
            retryCount--;
            if (retryCount == 0) {
              throw Exception('Không thể gửi FCM token sau nhiều lần thử');
            }
            await Future.delayed(Duration(seconds: 2));
          }
        }
      },
      customMessage: 'Không thể gửi token FCM',
    );
  }

  static Future<void> logout(BuildContext context) async {
    await SecureTokenStorage.deleteToken();
    await SecureTokenStorage.deleteUser();
    Provider.of<AuthProviderCheck>(context, listen: false).logout();
    Snack_Bar('Đã đăng xuất');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(initialIndex: 4)),
      (route) => false,
    );
  }

  // Headers tiêu chuẩn
  Map<String, String> _headers() => {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
      };

  static Map<String, String> _authHeaders(String? token) => {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
}
