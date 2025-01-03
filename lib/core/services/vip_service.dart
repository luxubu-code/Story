// lib/services/vip_service.dart

import 'package:dio/dio.dart';

import '../../routes/api_endpoints.dart';
import '../../storage/secure_tokenstorage.dart';

class VipService {
  final Dio _dio = Dio();

  // Lấy danh sách gói VIP
  Future<List<dynamic>> getPackages() async {
    final token = await SecureTokenStorage.getToken();
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/api/vip/packages',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data['packages'];
    } catch (e) {
      // Ném lỗi để widget xử lý việc hiển thị thông báo
      throw Exception('Không thể tải danh sách gói VIP: $e');
    }
  }

  // Đăng ký gói VIP và lấy URL thanh toán
  Future<String> subscribePackage(int packageId) async {
    final token = await SecureTokenStorage.getToken();
    try {
      final response = await _dio.post(
        '${ApiEndpoints.baseUrl}/api/vip/subscribe/$packageId',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );

      String paymentUrl = response.data['payment_url'];
      // Giải mã URL hai lần vì URL được encode hai lần từ backend
      paymentUrl = Uri.decodeFull(Uri.decodeFull(paymentUrl));

      if (paymentUrl.isEmpty || !Uri.parse(paymentUrl).isAbsolute) {
        throw Exception('URL thanh toán không hợp lệ');
      }

      return paymentUrl;
    } catch (e) {
      throw Exception('Lỗi khi đăng ký gói VIP: $e');
    }
  } // Trong VipService

  Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await SecureTokenStorage.getToken();
    try {
      final response = await _dio.get(
        '${ApiEndpoints.baseUrl}/api/user',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      return response.data['data'];
    } catch (e) {
      throw Exception('Không thể lấy thông tin người dùng: $e');
    }
  }
}
