import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:story/core/services/ApiHelper.dart';
import 'package:story/core/services/cache_manager.dart';

import '../../models/story.dart';
import '../../routes/api_endpoints.dart';

class StoryService {
  final CacheManager _cacheManager = CacheManager();

  // Future<List<Story>> fetchStories() async {
  //   const String key = 'all_stories';
  //
  //   final cacheStoris = CacheManager().getItem<List<Story>>(key);
  //   if (cacheStoris != null) {
  //     print('Fetching stories from cache');
  //     return cacheStoris;
  //   }
  //   try {
  //     final response = await http
  //         .get(Uri.parse(ApiEndpoints.getStories))
  //         .timeout(const Duration(seconds: 100));
  //
  //     if (response.statusCode == 200) {
  //       print('Fetching stories from API');
  //       final List<dynamic> responseData =
  //           jsonDecode(response.body)['data'] ?? [];
  //       final stories =
  //           responseData.map((storyJson) => Story.fromJson(storyJson)).toList();
  //       _cacheManager.setItem(key, stories,
  //           duration: const Duration(minutes: 15));
  //
  //       return stories;
  //     } else {
  //       throw HttpException('Failed to load stories: ${response.reasonPhrase}',
  //           uri: Uri.parse(ApiEndpoints.getStories));
  //     }
  //   } on SocketException {
  //     throw Exception('No Internet connection');
  //   } on TimeoutException {
  //     throw Exception('Connection timeout');
  //   } catch (e) {
  //     throw Exception('Unexpected error: $e');
  //   }
  // }

  Future<List<Story>> fetchStories() async {
    const String key = 'all_stories';

    final cacheStoris = CacheManager().getItem<List<Story>>(key);
    if (cacheStoris != null) {
      print('Fetching stories from cache');
      return cacheStoris;
    }
    try {
      final stories =
          await ApiHelper.fetchDataStory(url: ApiEndpoints.getStories);
      _cacheManager.setItem(key, stories,
          duration: const Duration(minutes: 15));
      print('Fetching stories from API');

      return stories;
    } catch (e) {
      print('Failed stories from API: $e');
      throw Exception('Failed to fetch stories');
    }
  }

  Future<void> views(int id) async {
    final url = Uri.parse('${ApiEndpoints.views}$id');
    try {
      final response =
          await http.post(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        print('views success');
      } else {
        print('views failed with status code: ${url}');
        print('views failed with status code: ${response.statusCode}');
      }
    } on TimeoutException {
      print('views timeout');
    } catch (e) {
      print('views error: $e');
    }
  }

  Future<Story> fetchStoriesDetail(int id) async {
    try {
      final response = await http
          .get(Uri.parse('${ApiEndpoints.getStories}/$id'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          print(responseData['data']);
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

  Future<List<Story>> fetchStoriesSearch(String searchQuery) async {
    final url =
        Uri.parse('${ApiEndpoints.getStoriesSearch}?search=$searchQuery');
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

  // Ranking and Filtering Methods
  Future<List<Story>> fetchStoryMostViews(int takeCount) async {
    try {
      final response = await fetchStories();
      response.sort((a, b) => b.views.compareTo(a.views));
      return response.take(takeCount).toList();
    } catch (error) {
      rethrow;
    }
  }

  Future<List<Story>> fetchStoryMostFavourite(int takeCount) async {
    try {
      final response = await fetchStories();
      response.sort((a, b) => b.favourite.compareTo(a.favourite));
      return response.take(takeCount).toList();
    } catch (error) {
      rethrow;
    }
  }
}
