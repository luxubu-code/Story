import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../models/image.dart';
import '../../routes/api_endpoints.dart';

class ImageService {
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
}
