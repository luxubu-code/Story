import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:story/routes/api_endpoints.dart';

import '../../../models/vip_subscription.dart';
import '../../../storage/secure_tokenstorage.dart';

// Ngoại lệ tùy chỉnh cho các lỗi liên quan đến đăng ký
class SubscriptionException implements Exception {
  final String message;
  final int? statusCode;

  SubscriptionException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class SubscriptionProvider with ChangeNotifier {
  final Dio dio;

  // Các biến trạng thái riêng tư với tên rõ ràng hơn
  List<VipSubscription> _subscriptionHistory = [];
  VipSubscription? _currentActiveSubscription;
  bool _isLoadingData = false;
  String? _errorMessage;

  // Thêm trạng thái để theo dõi trạng thái yêu cầu API
  bool _isRefreshing = false;
  DateTime? _lastFetchTime;

  SubscriptionProvider({required this.dio});

  // Các getter với xác thực và tính bất biến
  List<VipSubscription> get subscriptionHistory =>
      List.unmodifiable(_subscriptionHistory);

  VipSubscription? get activeSubscription => _currentActiveSubscription;

  bool get isLoading => _isLoadingData;

  String? get error => _errorMessage;

  bool get hasActiveSubscription => _currentActiveSubscription != null;

  // Cải thiện việc lấy lịch sử đăng ký với logic thử lại và bộ nhớ đệm
  Future<void> fetchSubscriptions({bool forceRefresh = false}) async {
    // Ngăn chặn các cuộc gọi trùng lặp trừ khi yêu cầu làm mới
    if (_isLoadingData && !forceRefresh) return;
    if (_isRefreshing) return;

    try {
      _setLoading(true);
      _isRefreshing = true;

      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/vip/history',
        options: Options(
          headers: await _getAuthHeaders(),
          validateStatus: (status) => status! < 500,
          // Thêm thời gian chờ hợp lý
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['data'] != null && data['data']['subscriptions'] != null) {
          _subscriptionHistory = (data['data']['subscriptions'] as List)
              .map((json) => VipSubscription.fromJson(json))
              .toList();

          // Sắp xếp đăng ký theo ngày bắt đầu (gần đây nhất trước)
          _subscriptionHistory
              .sort((a, b) => b.startDate.compareTo(a.startDate));

          _errorMessage = null;
          _lastFetchTime = DateTime.now();
          notifyListeners();
        } else {
          throw SubscriptionException(
              'Định dạng phản hồi từ máy chủ không hợp lệ');
        }
      } else {
        throw SubscriptionException(
          response.data['message'] ?? 'Không thể tải lịch sử đăng ký',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      _errorMessage = 'Đã xảy ra lỗi không mong muốn khi tải lịch sử đăng ký';
      debugPrint('Lỗi tải đăng ký: $e');
      rethrow;
    } finally {
      _setLoading(false);
      _isRefreshing = false;
    }
  }

  // Cải thiện việc lấy đăng ký đang hoạt động với xử lý lỗi tốt hơn
  Future<void> fetchActiveSubscription() async {
    try {
      final response = await dio.get(
        '${ApiEndpoints.baseUrl}/api/vip/history/active',
        options: Options(
          headers: await _getAuthHeaders(),
          validateStatus: (status) => status! < 500,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null) {
          _currentActiveSubscription = VipSubscription.fromJson(data['data']);
          _errorMessage = null;
        } else {
          // Không có đăng ký đang hoạt động là trạng thái hợp lệ
          _currentActiveSubscription = null;
        }
      } else {
        throw SubscriptionException(
          response.data['message'] ??
              'Không thể lấy thông tin đăng ký đang hoạt động',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      _currentActiveSubscription = null;
    } catch (e) {
      _errorMessage =
          'Đã xảy ra lỗi không mong muốn khi lấy thông tin đăng ký đang hoạt động';
      debugPrint('Lỗi lấy đăng ký đang hoạt động: $e');
      _currentActiveSubscription = null;
    } finally {
      notifyListeners();
    }
  }

  // Cải thiện xử lý lỗi với thông báo lỗi cụ thể hơn
  void _handleDioError(DioException e) {
    _errorMessage = switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout =>
        'Hết thời gian kết nối. Vui lòng kiểm tra kết nối internet của bạn.',
      DioExceptionType.connectionError =>
        'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối internet của bạn.',
      _ when e.response?.statusCode == 401 =>
        'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      _ when e.response?.statusCode == 403 =>
        'Truy cập bị từ chối. Vui lòng kiểm tra trạng thái đăng ký của bạn.',
      _ when e.response?.data?['message'] != null =>
        e.response!.data['message'],
      _ => 'Đã xảy ra lỗi. Vui lòng thử lại sau.',
    };
  }

  // Tạo header bảo mật với xác thực token
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await SecureTokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw SubscriptionException('Không tìm thấy token xác thực');
    }

    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  void _setLoading(bool value) {
    _isLoadingData = value;
    notifyListeners();
  }

  // Các phương thức tiện ích bổ sung
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Phương thức kiểm tra xem dữ liệu có cần làm mới không
  bool get needsRefresh {
    if (_lastFetchTime == null) return true;
    return DateTime.now().difference(_lastFetchTime!) >
        const Duration(minutes: 5);
  }

  // Phương thức dọn dẹp
  void dispose() {
    _subscriptionHistory.clear();
    _currentActiveSubscription = null;
    super.dispose();
  }
}
