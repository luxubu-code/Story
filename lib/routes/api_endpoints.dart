class ApiEndpoints {
  // static const String baseUrl = 'http://10.0.2.2:8000';

  static const String baseUrl = 'http://192.168.2.171:8000';

  // static const String baseUrl = 'http://0.0.0.0:8000';

  // static const String baseUrl = 'http://192.168.227.95:8000';

  // static const String baseUrl = 'http://172.22.10.90:8000';

  static const String updateProfile = '$baseUrl/api/user';
  static const String getUser = '$baseUrl/api/user';

  //Search
  static const String getStoriesSearch = '$baseUrl/api/stories/search';

  //Story
  static const String getStories = '$baseUrl/api/stories';

  //Comment
  static const String comment = '$baseUrl/api/comment';

  //History
  static const String history = '$baseUrl/api/history/';

  //Favourite
  static const String getFavourite = '$baseUrl/api/favourite';
  static const String postFavourite = '$baseUrl/api/favourite/';
  static const String checkFavourite = '$baseUrl/api/favourite/exists/';
  static const String deleteFavourite = '$baseUrl/api/favourite/';

  //Image
  static const String getImages = '$baseUrl/api/images/';

  //loginvsgoogle
  static const String postGoogle = '$baseUrl/api/auth/google';

  //
  static const String getRatings = '$baseUrl/api/rating/';
  static const String postRatings = '$baseUrl/api/rating';

  //User
  static const String login = '$baseUrl/api/auth/login';
  static const String sendFcm = '$baseUrl/api/send-fcmToken';
  static const String register = '$baseUrl/api/auth/register';
}
