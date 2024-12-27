import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../utils/Snackbar.dart';

class ApiService {
  static Future<Map<String, dynamic>> request({
    required String url,
    required String method, // "GET", "POST", "PUT", "DELETE", "MULTIPART"
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    String? token,
    bool isJson = true,
    String? imagePath, // Đường dẫn file cho MultipartRequest
    Duration timeout = const Duration(seconds: 30),
  }) async {
    try {
      final Map<String, String> defaultHeaders = {
        "Accept": "application/json",
        "Content-Type":
            isJson ? "application/json" : "application/x-www-form-urlencoded",
      };

      if (token != null) {
        defaultHeaders["Authorization"] = "Bearer $token";
      }

      if (headers != null) {
        defaultHeaders.addAll(headers);
      }

      http.Response response;

      // Xử lý các loại request khác nhau
      switch (method.toUpperCase()) {
        case "GET":
          response = await http
              .get(Uri.parse(url), headers: defaultHeaders)
              .timeout(timeout);
          break;

        case "POST":
          response = await http
              .post(Uri.parse(url),
                  headers: defaultHeaders,
                  body: isJson ? json.encode(body) : body)
              .timeout(timeout);
          print('API Response Status Code: ${response.statusCode}');
          print('API Response Body: ${response.body}');
          break;

        case "PUT":
          response = await http
              .put(Uri.parse(url),
                  headers: defaultHeaders,
                  body: isJson ? json.encode(body) : body)
              .timeout(timeout);
          break;

        case "DELETE":
          response = await http
              .delete(Uri.parse(url), headers: defaultHeaders)
              .timeout(timeout);
          break;

        case "MULTIPART":
          // Xử lý MultipartRequest
          final request = http.MultipartRequest('POST', Uri.parse(url))
            ..headers.addAll(defaultHeaders);

          // Thêm các field từ body
          if (body != null) {
            body.forEach((key, value) {
              if (value != null) {
                request.fields[key] = value.toString();
              }
            });
          }

          // Thêm file nếu có
          if (imagePath != null && imagePath.isNotEmpty) {
            try {
              request.files.add(await http.MultipartFile.fromPath(
                  'image', imagePath)); // Thay key 'image' nếu cần
            } catch (e) {
              Snack_Bar('Không thể tải file: $e');
              throw Exception('Error adding file: $e');
            }
          }

          // Gửi request và xử lý phản hồi
          final streamedResponse = await request.send();
          final responseBody = await streamedResponse.stream.bytesToString();

          if (streamedResponse.statusCode == 200) {
            return json.decode(responseBody);
          } else {
            final Map<String, dynamic> errorData =
                json.decode(responseBody) as Map<String, dynamic>;
            Snack_Bar('Lỗi API: ${errorData['message'] ?? 'Không rõ lỗi'}');
            throw Exception(
                'Failed with status: ${streamedResponse.statusCode}, ${errorData['message']}');
          }

        default:
          throw Exception("Unsupported HTTP method: $method");
      }

      // Kiểm tra phản hồi từ server
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final Map<String, dynamic> errorData =
            json.decode(response.body) as Map<String, dynamic>;
        Snack_Bar('Lỗi API: ${errorData['message'] ?? 'Không rõ lỗi'}');
        throw Exception(
            'Failed with status: ${response.statusCode}, ${errorData['message']}');
      }
    } on SocketException {
      Snack_Bar('Không có kết nối Internet');
      throw Exception('No Internet connection');
    } on TimeoutException {
      Snack_Bar('Quá thời gian kết nối');
      throw Exception('Connection timeout');
    } catch (e) {
      Snack_Bar('Lỗi không mong đợi: $e');
      throw Exception('Unexpected error: $e');
    }
  }
}
