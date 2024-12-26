import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../models/comment.dart';
import '../../routes/api_endpoints.dart';
import '../../storage/secure_tokenstorage.dart';

class CommentService {
  Future<bool> postComment(int storyId, int? parentId, String content) async {
    final String? token = await SecureTokenStorage.getToken();
    final url = Uri.parse(ApiEndpoints.comment);
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final Map<String, dynamic> body = {
      'story_id': '$storyId',
      'content': '$content',
    };
    if (parentId != null) {
      body['parent_id'] = parentId;
    }
    try {
      final response = await http
          .post(url, headers: headers, body: jsonEncode(body))
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

  Future<List<Comment>> fetchComment(int id) async {
    try {
      final response = await http
          .get(
            Uri.parse('${ApiEndpoints.comment}/$id'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final List<dynamic> responseData = jsonResponse['data'] ?? [];
        return responseData
            .map((storyJson) => Comment.fromJson(storyJson))
            .toList();
      } else {
        throw HttpException('Failed to load comment: ${response.reasonPhrase}',
            uri: Uri.parse(ApiEndpoints.comment));
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<List<Comment>> fetchMostLikesComment(int takeCount, int id) async {
    try {
      final response = await fetchComment(id);
      response.sort((a, b) => b.like.compareTo(a.like));
      return response.take(takeCount).toList();
    } catch (error) {
      rethrow;
    }
  }
}
