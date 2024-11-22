import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../models/comment.dart';
import '../../models/image.dart';
import '../../models/story.dart';
import '../../routes/api_endpoints.dart';
import '../../storage/secure_tokenstorage.dart';

class StoryService {
  DateTime getStartOfWeek(DateTime datetime) {
    return datetime.subtract(Duration(days: datetime.weekday - 1));
  }

  DateTime getEndOfWeek(DateTime datetime) {
    return datetime
        .subtract(Duration(days: DateTime.daysPerWeek - datetime.weekday));
  }

  Future<List<Story>> fetchStories() async {
    try {
      final response = await http
          .get(Uri.parse(ApiEndpoints.getStories))
          .timeout(const Duration(seconds: 100));

      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            jsonDecode(response.body)['data'] ?? [];
        return responseData
            .map((storyJson) => Story.fromJson(storyJson))
            .toList();
      } else {
        throw HttpException('Failed to load stories: ${response.reasonPhrase}',
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

  Future<List<Story>> fetchStoryMostViews(int takecount) async {
    try {
      final response = await fetchStories(); // Hoặc gọi API cụ thể nếu có
      response.sort((a, b) =>
          b.views.compareTo(a.views)); // Sắp xếp theo số lượt xem (views)
      return response.take(takecount).toList();
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Story>> fetchStoryMostFavourite(int takecount) async {
    try {
      final response = await fetchStories(); // Hoặc gọi API cụ thể nếu có
      response.sort((a, b) => b.favourite
          .compareTo(a.favourite)); // Sắp xếp theo số lượt xem (views)
      return response.take(takecount).toList();
    } catch (error) {
      rethrow;
    }
  }

  // Future<List<Story>> fetchStoryMostViewsInWeek(int takecount) async {
  //   DateTime startOfWeeek = getStartOfWeek(DateTime.now());
  //   DateTime endOfWeeek = getEndOfWeek(DateTime.now());
  //   try {
  //     final response = await fetchStories(); // Hoặc gọi API cụ thể nếu có
  //     response.sort((a, b) =>
  //         b.views.compareTo(a.views)); // Sắp xếp theo số lượt xem (views)
  //     return response
  //         .take(takecount)
  //         .toList(); // Lấy top 5 truyện có lượt xem cao nhất
  //   } catch (error) {
  //     rethrow;
  //   }
  //   // Lọc các truyện có `read_at` nằm trong khoảng tuần hiện tại
  //   return stories.where((story) {
  //     return story.read_at.isAfter(startOfWeek) && story.read_at.isBefore(endOfWeek);
  //   }).toList();
  // }

  Future<List<ImagePath>> fetchImage(int id) async {
    final url = Uri.parse('${ApiEndpoints.getImages}$id');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            jsonDecode(response.body)['data'] ?? [];
        return responseData
            .map((imageJson) => ImagePath.fromJson(imageJson))
            .toList();
      } else {
        throw HttpException('Failed to load stories: ${response.reasonPhrase}',
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

  Future<Story> fetchStoriesDetail(int id) async {
    try {
      print('getstoris s ${ApiEndpoints.getStories}/$id');
      final response = await http
          .get(Uri.parse('${ApiEndpoints.getStories}/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return Story.fromJson(responseData['data']);
        } else {
          throw Exception('Failed to load story: ${responseData['message']}');
        }
      } else {
        throw HttpException('Failed to load story: ${response.reasonPhrase}',
            uri: Uri.parse('${ApiEndpoints.getStories}/$id'));
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

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
      print('Not login');
      return false; // Dừng hàm nếu không có token
    }
    final url = Uri.parse('${ApiEndpoints.checkFavourite}$id');
    print(url);
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
        if (responseData['exists'] == true) {
          print(true);
          return true;
        } else {
          print(false);
          return false;
        }
      } else {
        print('Failed to check ${response.statusCode}');
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
        if (responseData['status'] == 'success') {
          return true;
        } else {
          print('Failed to add to favorites: ${responseData['message']}');
          return false;
        }
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
        if (responseData['exists'] == true) {
          print(true);
          return true;
        } else {
          print(false);
          return false;
        }
      } else {
        print('Failed to delete ${response.statusCode}');
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

  Future<List<Story>> fetchStoriesSearch(String cc) async {
    final url = Uri.parse('${ApiEndpoints.getStoriesSearch}?search=$cc');
    final headers = {
      'Content-Type': 'application/json',
    };
    try {
      final response = await http
          .get(
            url,
            headers: headers,
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> responseData =
            jsonDecode(response.body)['data'] ?? [];
        return responseData
            .map((storyJson) => Story.fromJson(storyJson))
            .toList();
      } else {
        throw HttpException('Failed to load stories: ${response.reasonPhrase}',
            uri: Uri.parse(ApiEndpoints.getStoriesSearch));
      }
    } on SocketException {
      throw Exception('No Internet connection');
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> postHistory(
    int story_id,
    int chapter_id,
  ) async {
    final String? token = await SecureTokenStorage.getToken();
    final url = Uri.parse(ApiEndpoints.history);
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    final body =
        jsonEncode({'story_id': '$story_id', 'chapter_id': '$chapter_id'});
    try {
      final response = await http
          .post(url, headers: headers, body: body)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return true;
        } else {
          print('Failed to add to history: ${responseData['message']}');
          return false;
        }
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

  Future<bool> postComment(int story_id, int? parent_id, String content) async {
    final String? token = await SecureTokenStorage.getToken();
    final url = Uri.parse(ApiEndpoints.comment);
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    final Map<String, dynamic> body = {
      'story_id': '$story_id',
      'content': '$content',
    };
    if (parent_id != null) {
      body['parent_id'] = parent_id;
    }
    try {
      final response = await http
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return true;
        } else {
          print('Failed to add to history: ${responseData['message']}');
          return false;
        }
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

  Future<List<Comment>> fetchMostLikesComment(int takecount, int id) async {
    try {
      final response = await fetchComment(id); // Hoặc gọi API cụ thể nếu có
      response.sort((a, b) =>
          b.like.compareTo(a.like)); // Sắp xếp theo số lượt xem (views)
      return response.take(takecount).toList();
    } catch (error) {
      rethrow;
    }
  }
}
