import '../../models/story.dart';
import '../../routes/api_endpoints.dart';
import '../../storage/secure_tokenstorage.dart';
import 'api_service.dart';

class FavouriteService {
  Future<List<Story>> fetchStoriesFavourite() async {
    try {
      String? token = await SecureTokenStorage.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await ApiService.request(
        url: ApiEndpoints.getFavourite,
        method: "GET",
        token: token,
      );

      final List<dynamic> responseData = response['data'] ?? [];
      return responseData
          .map((storyJson) => Story.fromJson(storyJson))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkStoriesFavourite(int id) async {
    try {
      String? token = await SecureTokenStorage.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await ApiService.request(
        url: '${ApiEndpoints.checkFavourite}$id',
        method: "GET",
        token: token,
      );

      return response['exists'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> postStoriesFavourite(int id) async {
    try {
      String? token = await SecureTokenStorage.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await ApiService.request(
        url: ApiEndpoints.postFavourite,
        method: "POST",
        token: token,
        body: {'story_id': id},
      );

      return response['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteStoriesFavourite(int id) async {
    try {
      String? token = await SecureTokenStorage.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await ApiService.request(
        url: '${ApiEndpoints.deleteFavourite}$id',
        method: "DELETE",
        token: token,
      );

      return response['status'] == 'success';
    } catch (e) {
      rethrow;
    }
  }
}
