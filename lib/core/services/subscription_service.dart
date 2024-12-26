import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:story/routes/api_endpoints.dart';
import 'package:story/storage/secure_tokenstorage.dart';

import '../../models/subscription.dart';

class SubscriptionService {
  // Lấy subscription hiện tại
  Future<Subscription?> getCurrentSubscription() async {
    try {
      final token = await SecureTokenStorage.getToken();
      final response = await http.get(
        Uri.parse(ApiEndpoints.current),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Kiểm tra nếu data là mảng rỗng thì trả về null
        if (data['data'] is List && (data['data'] as List).isEmpty) {
          return null;
        }
        // Nếu có dữ liệu thì parse thành đối tượng Subscription
        if (data['data'] != null && data['data'] is Map<String, dynamic>) {
          return Subscription.fromJson(data['data']);
        }
        return null;
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền truy cập');
      } else {
        throw Exception('Không thể tải thông tin gói đăng ký');
      }
    } catch (e) {
      print('getCurrentSubscription Lỗi: $e');
      throw Exception('Đã xảy ra lỗi khi tải thông tin gói đăng ký: $e');
    }
  }

  // Lấy lịch sử đăng ký
  Future<List<Subscription>> getSubscriptionHistory() async {
    try {
      final token = await SecureTokenStorage.getToken();
      final response = await http.get(
        Uri.parse(ApiEndpoints.history),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Kiểm tra nếu data là mảng rỗng
        if (data['data'] is List && (data['data'] as List).isEmpty) {
          return []; // Trả về mảng rỗng
        }

        // Parse dữ liệu một cách an toàn
        final List<dynamic> historyList = data['data'] as List;
        return historyList
            .map((item) {
              try {
                return Subscription.fromJson(item);
              } catch (e) {
                print('Lỗi khi parse subscription: $e');
                return null;
              }
            })
            .whereType<Subscription>()
            .toList(); // Lọc bỏ các giá trị null
      } else if (response.statusCode == 401) {
        throw Exception('Không có quyền truy cập');
      } else {
        throw Exception('Không thể tải lịch sử đăng ký');
      }
    } catch (e) {
      print('getSubscriptionHistory Lỗi: $e');
      // Trong trường hợp lỗi, trả về mảng rỗng thay vì throw exception
      return [];
    }
  }

  // Đăng ký gói mới
  Future<String> purchaseSubscription(int packageId) async {
    try {
      final token = await SecureTokenStorage.getToken();
      final response = await http.post(
        Uri.parse(ApiEndpoints.purchase),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'package_id': packageId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['payment_url'];
      } else {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Không thể thực hiện thanh toán');
      }
    } catch (e) {
      print('purchaseSubscription Lỗi: $e');
      throw Exception('Đã xảy ra lỗi khi thực hiện thanh toán: $e');
    }
  }

  Future<bool> handleVNPayReturn(Map<String, dynamic> vnpParams) async {
    try {
      final token = await SecureTokenStorage.getToken();
      final response = await http.post(
        Uri.parse(ApiEndpoints.vnpayReturn),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(vnpParams),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return true;
        } else {
          throw Exception(data['message'] ?? 'Thanh toán không thành công');
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(
            error['message'] ?? 'Lỗi khi xử lý dữ liệu phản hồi từ VNPay');
      }
    } catch (e) {
      print('handleVNPayReturn Lỗi: $e');
      throw Exception('Đã xảy ra lỗi khi xử lý phản hồi từ VNPay: $e');
    }
  }
}
