import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:story/models/story.dart';

class ApiHelper {
  static Future<dynamic> fetchData({
    required String url,
    String method = 'GET',
    Map<String, String>? headers,
    bool isJson = true,
    String? token,
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 10),
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

      // Xử lý các phương thức HTTP
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(Uri.parse(url), headers: defaultHeaders)
              .timeout(timeout);
          break;
        case 'POST':
          response = await http
              .post(Uri.parse(url), headers: headers, body: jsonEncode(body))
              .timeout(timeout);
          break;
        case 'DELETE':
          response = await http
              .delete(Uri.parse(url), headers: headers)
              .timeout(timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // Xử lý kết quả phản hồi từ server
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw HttpException(
          'HTTP Error: ${response.statusCode} ${response.reasonPhrase}',
          uri: Uri.parse(url),
        );
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  static Future<List<Story>> fetchDataStory({
    required String url,
    String method = 'GET',
    Map<String, String>? headers,
    bool isJson = true,
    String? token,
    Map<String, dynamic>? body,
    Duration timeout = const Duration(seconds: 10),
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

      // Xử lý các phương thức HTTP
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http
              .get(Uri.parse(url), headers: defaultHeaders)
              .timeout(timeout);
          print(response.body);
          break;
        case 'POST':
          response = await http
              .post(Uri.parse(url), headers: headers, body: jsonEncode(body))
              .timeout(timeout);
          break;
        case 'DELETE':
          response = await http
              .delete(Uri.parse(url), headers: headers)
              .timeout(timeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      // Xử lý kết quả phản hồi từ server
      if (response.statusCode == 200) {
        print('Fetching stories from API');
        final List<dynamic> responseData =
            jsonDecode(response.body)['data'] ?? [];
        final stories =
            responseData.map((storyJson) => Story.fromJson(storyJson)).toList();
        print(response.body);
        return stories;
      } else {
        throw HttpException(
          'HTTP Error: ${response.statusCode} ${response.reasonPhrase}',
          uri: Uri.parse(url),
        );
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
