import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../models/story.dart';
import '../../routes/api_endpoints.dart';
import '../../storage/secure_tokenstorage.dart';

class FavouriteService {
  Future<List<Story>> fetchStoriesFavourite() async {
    try {
      String? token = await SecureTokenStorage.getToken();
      final response = await http.get(
        Uri.parse(ApiEndpoints.getFavourite),
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
            uri: Uri.parse(ApiEndpoints.getFavourite));
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> checkStoriesFavourite(int id) async {
    String? token = await SecureTokenStorage.getToken();
    if (token == null || token.isEmpty) {
      return false;
    }
    final url = Uri.parse('${ApiEndpoints.checkFavourite}$id');
    final headers = {
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http
          .get(
            url,
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['exists'] == true;
      } else {
        throw HttpException('Failed to check ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> postStoriesFavourite(int id) async {
    try {
      final String? token = await SecureTokenStorage.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      final url = Uri.parse(ApiEndpoints.postFavourite);
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({'story_id': id});
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

  Future<bool> deleteStoriesFavourite(int id) async {
    try {
      final String? token = await SecureTokenStorage.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      final url = Uri.parse('${ApiEndpoints.deleteFavourite}$id');
      final headers = {
        'Authorization': 'Bearer $token',
      };
      final response = await http
          .delete(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['exists'] == true;
      } else {
        throw HttpException('Failed to delete ${response.statusCode}');
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
