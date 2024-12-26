import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../utils/Snackbar.dart';

enum ErrorType { network, authentication, validation, server, unknown }

class ErrorHandler {
  // Xử lý lỗi và trả về thông báo phù hợp
  static Future<T> handleError<T>({
    required Future<T> Function() operation,
    BuildContext? context,
    String customMessage = '',
  }) async {
    try {
      return await operation();
    } catch (e) {
      // Phân loại lỗi
      final errorType = _categorizeError(e);

      // Tạo thông báo lỗi
      final errorMessage = _getErrorMessage(errorType, e, customMessage);

      // Hiển thị thông báo cho người dùng
      _showError(context!, errorMessage);

      // Log lỗi để debug
      print('Lỗi [$errorType]: $errorMessage');

      // Ném lại lỗi nếu cần
      rethrow;
    }
  }

  // Phân loại lỗi
  static ErrorType _categorizeError(dynamic error) {
    if (error is SocketException || error is TimeoutException) {
      return ErrorType.network;
    } else if (error is FirebaseAuthException) {
      return ErrorType.authentication;
    } else if (error.toString().contains('status code: 4')) {
      return ErrorType.validation;
    } else if (error.toString().contains('status code: 5')) {
      return ErrorType.server;
    }
    return ErrorType.unknown;
  }

  // Tạo thông báo lỗi phù hợp
  static String _getErrorMessage(
      ErrorType type, dynamic error, String customMessage) {
    if (customMessage.isNotEmpty) return customMessage;

    switch (type) {
      case ErrorType.network:
        return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.';
      case ErrorType.authentication:
        return 'Lỗi xác thực: ${error.message}';
      case ErrorType.validation:
        return 'Dữ liệu không hợp lệ. Vui lòng kiểm tra lại.';
      case ErrorType.server:
        return 'Lỗi máy chủ. Vui lòng thử lại sau.';
      case ErrorType.unknown:
        return 'Đã xảy ra lỗi không xác định.';
    }
  }

  // Hiển thị thông báo lỗi
  static void _showError(BuildContext context, String message) {
    Snack_Bar(message);
  }
}
