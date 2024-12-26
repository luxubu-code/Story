import 'package:dio/dio.dart';

class DioErrorHandler {
  static Exception handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Kết nối bị gián đoạn, vui lòng thử lại');

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final data = error.response?.data;

          if (statusCode == 401) {
            return Exception('Phiên đăng nhập đã hết hạn');
          }

          if (data != null && data['message'] != null) {
            return Exception(data['message']);
          }
          return Exception('Đã có lỗi xảy ra');

        case DioExceptionType.connectionError:
          return Exception('Không thể kết nối đến máy chủ');

        default:
          return Exception('Đã có lỗi xảy ra, vui lòng thử lại sau');
      }
    }
    return Exception(error.toString());
  }
}
