import 'dart:async';
import 'dart:convert';
import 'dart:io';

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

class AuthService {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<Map<String, dynamic>?> signInWithGoogle(BuildContext context) async {
    // Kiểm tra xem đã có người dùng đăng nhập sẵn chưa
    try {
      final GoogleSignInAccount? currentUser =
          await googleSignIn.signInSilently();
      final token = await SecureTokenStorage.getToken();

      if (currentUser != null) {
        print("Người dùng đã đăng nhập sẵn: ${currentUser.email}");
        return await _handleSignIn(currentUser, context);
      }
      if (token == null) {
        await googleSignIn.signOut();
        print("không có token");
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print("Người dùng đã hủy đăng nhập");
        return null;
      }
      return await _handleSignIn(googleUser, context);
    } catch (e) {
      print(
          '====================================================================================================================');
      print('Lỗi chi tiết: $e');
    }
  }

  Future<Map<String, dynamic>> _handleSignIn(
      GoogleSignInAccount googleUser, BuildContext context) async {
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final response = await http.post(
      Uri.parse(ApiEndpoints.postGoogle),
      body: {'idToken': googleAuth.idToken},
    );
    print(
        '====================================================================================================================');
    print(googleAuth.idToken);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      await SecureTokenStorage.saveToken(data['access_token']);
      final token = data['access_token'];

      if (token != null) {
        final authProvider =
            Provider.of<AuthProviderCheck>(context, listen: false);
        await authProvider.login(token);
        print('Login successful, token saved.');
      } else {
        print('Login failed: Token not found in response.');
      }
      UserModel user = UserModel.fromJson(data['user']);
      await SecureTokenStorage.saveUser(user);
      return data;
    } else {
      print('Server responded with status: ${response.statusCode}');
      print('Response body: ${response.body}');
      throw Exception('Failed to authenticate with server');
    }
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    final url = Uri.parse(ApiEndpoints.login);
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded"
    };
    final body = {'email': email, 'password': password};

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        await SecureTokenStorage.saveToken(data['access_token']);
        UserModel user = UserModel.fromJson(data['user']);
        await SecureTokenStorage.saveUser(user);
        final token = data['access_token'];

        if (token != null) {
          final authProvider =
              Provider.of<AuthProviderCheck>(context, listen: false);
          await authProvider.login(token);
          print('Login successful, token saved.');
        } else {
          print('Login failed: Token not found in response.');
        }
      } else {
        print('Failed to send request: ${response.statusCode}.');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<void> register(
      String email, String password, String password_confirmation) async {
    final url = Uri.parse(ApiEndpoints.register);
    print(url);
    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded"
    };
    final body = {
      'email': email,
      'password': password,
      'password_confirmation': password_confirmation
    };
    print(body);

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final status = responseData['status'];
        if (status == 'success') {
          print('register success');
          Snack_Bar('register success');
        } else {
          print('register failed');
          Snack_Bar('register failed');
        }
      } else {
        print('Failed to send request: ${response.statusCode}.');
        Snack_Bar('Failed to send request: ${response.statusCode}.');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<void> sendFcm(String fcmToken) async {
    String? token = await SecureTokenStorage.getToken();

    // Kiểm tra nếu token là null hoặc rỗng, thì không thực hiện gửi
    if (token == null || token.isEmpty) {
      print('No token available, skipping FCM send');
      return; // Dừng hàm nếu không có token
    }

    final url = Uri.parse(ApiEndpoints.sendFcm);
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({'token': fcmToken});
    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('FCM Token sent successfully');
        print(response.body);
      } else {
        print('Failed to send FCM Token. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM Token: $e');
    }
  }

  static Future<void> logout(BuildContext context) async {
    // await SecureTokenStorage.deleteToken();
    final authProvider = Provider.of<AuthProviderCheck>(context, listen: false);
    await SecureTokenStorage.deleteUser();
    await SecureTokenStorage.deleteToken();
    await authProvider
        .logout(); // Gọi phương thức logout từ AuthProvider để cập nhật trạng thái
    Snack_Bar('Đã đăng xuất');
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
    // URL endpoint của API
    final url = Uri.parse(ApiEndpoints.updateProfile);

    // Tạo request Multipart
    final request = http.MultipartRequest('POST', url)
      ..headers['Authorization'] = 'Bearer $token' // Gửi token xác thực
      ..fields['name'] = name
      ..fields['date_of_birth'] = dateOfBirth;
    if (imagePath != null && imagePath.isNotEmpty) {
      try {
        request.files
            .add(await http.MultipartFile.fromPath('image', imagePath));
      } catch (e) {
        Snack_Bar('Không thể tải lên hình ảnh: $e');
        return;
      }
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);
        Snack_Bar('Cập nhật thông tin thành công');
        print('Cập nhật thành công: ${data['message']}');
      } else {
        final responseBody = await response.stream.bytesToString();
        final errorData = jsonDecode(responseBody);
        Snack_Bar('Cập nhật thất bại: ${errorData['message']}');
        print('Chi tiết lỗi: ${errorData['errors']}');
      }
    } catch (e) {
      Snack_Bar('Lỗi trong quá trình cập nhật: $e');
      print('Lỗi khi cập nhật tài khoản: $e');
    }
  }

  Future<UserModel> fetchUser() async {
    String? token = await SecureTokenStorage.getToken();
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    try {
      final response = await http
          .get(Uri.parse(ApiEndpoints.getUser), headers: headers)
          .timeout(const Duration(seconds: 100)); // Giới hạn thời gian chờ

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['status'] == 'success' &&
            jsonResponse['data'] != null) {
          return UserModel.fromJson(jsonResponse['data']);
        } else {
          final errorMessage =
              'API Error: ${jsonResponse['message'] ?? 'Unknown error'}';
          print(errorMessage);
          throw Exception(errorMessage);
        }
      } else {
        final errorMessage =
            'Failed to fetch user data: ${response.reasonPhrase}';
        print(errorMessage);
        throw HttpException(
          errorMessage,
          uri: Uri.parse(ApiEndpoints.getUser),
        );
      }
    } on SocketException catch (e) {
      final errorMessage = 'No Internet connection: $e';
      print(errorMessage);
      throw Exception(errorMessage);
    } on TimeoutException catch (e) {
      final errorMessage = 'Connection timeout: $e';
      print(errorMessage);
      throw Exception(errorMessage);
    } catch (e) {
      final errorMessage = 'Unexpected error: $e';
      print(errorMessage);
      throw Exception(errorMessage);
    }
  }
}
