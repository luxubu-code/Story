import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../models/story.dart';
import '../../routes/api_endpoints.dart';
import '../../storage/secure_tokenstorage.dart';

class HistoryService {
  Future<bool> postHistory(int storyId, int chapterId) async {
    final String? token = await SecureTokenStorage.getToken();
    final url = Uri.parse(ApiEndpoints.history);
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    final body =
        jsonEncode({'story_id': '$storyId', 'chapter_id': '$chapterId'});
    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['status'] == 'success';
      } else {
        throw HttpException(
            'Request failed with status: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on TimeoutException {
      throw Exception('Request timed out');
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}');
    } on FormatException {
      throw Exception('Bad response format');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<Story>> fetchHistory() async {
    try {
      String? token = await SecureTokenStorage.getToken();
      final response = await http.get(
        Uri.parse(ApiEndpoints.history),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> responseData = jsonResponse['data'] ?? [];
        return responseData
            .map((storyJson) => Story.fromJson(storyJson))
            .toList();
      } else {
        throw HttpException('Failed to load stories: ${response.reasonPhrase}',
            uri: Uri.parse(ApiEndpoints.history));
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
