import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  ApiException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: 'Kết nối mạng không ổn định, vui lòng thử lại',
          errorCode: 'NETWORK_ERROR',
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message:
              'Không thể kết nối đến máy chủ, vui lòng kiểm tra kết nối mạng',
          errorCode: 'CONNECTION_ERROR',
        );

      case DioExceptionType.badResponse:
        final response = error.response;
        final statusCode = response?.statusCode;
        final data = response?.data;

        if (statusCode == 401) {
          return ApiException(
            message: 'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại',
            statusCode: statusCode,
            errorCode: 'UNAUTHORIZED',
          );
        }

        if (statusCode == 403) {
          return ApiException(
            message: 'Bạn không có quyền thực hiện thao tác này',
            statusCode: statusCode,
            errorCode: 'FORBIDDEN',
          );
        }

        if (data != null && data['message'] != null) {
          return ApiException(
            message: data['message'],
            statusCode: statusCode,
            errorCode: data['error_code'],
          );
        }

        return ApiException(
          message: 'Đã có lỗi xảy ra, vui lòng thử lại sau',
          statusCode: statusCode,
          errorCode: 'UNKNOWN_ERROR',
        );

      default:
        return ApiException(
          message: 'Đã có lỗi xảy ra, vui lòng thử lại sau',
          errorCode: 'UNKNOWN_ERROR',
        );
    }
  }
}

class ApiErrorHandler {
  static void showError(BuildContext context, dynamic error) {
    String message;
    if (error is ApiException) {
      message = error.message;
    } else {
      message = 'Đã có lỗi xảy ra, vui lòng thử lại sau';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Đóng',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
