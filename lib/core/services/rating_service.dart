import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:story/models/ratings.dart';

import '../../routes/api_endpoints.dart';
import '../../storage/secure_tokenstorage.dart';
import 'error_handling_service.dart';

class RatingService {
  Future<List<Ratings>> fetchRatings(int story_id) async {
    final url = Uri.parse('${ApiEndpoints.getRatings}$story_id');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            jsonDecode(response.body)['data'] ?? [];
        return responseData
            .map((ratingsJson) => Ratings.fromJson(ratingsJson))
            .toList();
      } else {
        throw HttpException('Failed to load Ratings: ${response.reasonPhrase}',
            uri: Uri.parse(ApiEndpoints.getStories));
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> postRatings(int storyId, int rating, String title) async {
    try {
      final String? token = await SecureTokenStorage.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      final url = Uri.parse(ApiEndpoints.postRatings);
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'story_id': storyId,
        'rating': rating,
        'title': title,
      });
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

  Future<bool> deleteRating(int id, BuildContext context) async {
    return await ErrorHandler.handleError(
      operation: () async {
        final String? token = await SecureTokenStorage.getToken();
        final url = Uri.parse('${ApiEndpoints.deleteRatings}/$id');
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
      customMessage: 'Không thể xóa đánh giá. Vui lòng thử lại sau.',
    );
  }
}
