import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/comment.dart';
import '../../routes/api_endpoints.dart';
import '../../storage/secure_tokenstorage.dart';
import 'error_handling_service.dart';

class CommentService {
  Future<bool> postComment(
      int storyId, int? parentId, String content, BuildContext context) async {
    return await ErrorHandler.handleError(
      operation: () async {
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
      },
      context: context,
      customMessage: 'Không thể đăng bình luận. Vui lòng thử lại sau.',
    );
  }

  Future<bool> deleteComment(int id, BuildContext context) async {
    return await ErrorHandler.handleError(
      operation: () async {
        final String? token = await SecureTokenStorage.getToken();
        final url = Uri.parse('${ApiEndpoints.comment}/$id');
        final headers = {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };
        final response = await http
            .delete(url, headers: headers)
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          return responseData['status'] == 'success';
        } else {
          throw HttpException(
              'Request failed with status: ${response.statusCode}');
        }
      },
      context: context,
      customMessage: 'Không thể đăng bình luận. Vui lòng thử lại sau.',
    );
  }

  Future<List<Comment>> fetchComment(int id, BuildContext context) async {
    return await ErrorHandler.handleError(
      operation: () async {
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
          throw HttpException(
              'Failed to load comment: ${response.reasonPhrase}');
        }
      },
      context: context,
      customMessage: 'Không thể tải bình luận. Vui lòng kiểm tra lại.',
    );
  }

  Future<List<Comment>> fetchMostLikesComment(
      int takeCount, int id, BuildContext context) async {
    return await ErrorHandler.handleError(
      operation: () async {
        final response = await fetchComment(id, context);
        response.sort((a, b) => b.like.compareTo(a.like));
        return response.take(takeCount).toList();
      },
      context: context,
      customMessage: 'Không thể tải bình luận có nhiều lượt thích nhất.',
    );
  }
}
