import 'package:story/models/user_model.dart';

class Ratings {
  final int? user_id;
  final int? story_id;
  final int rating;
  final String title;
  final List<UserModel> user;
  final DateTime created_at;

  Ratings(
      {required this.user_id,
      required this.story_id,
      required this.rating,
      required this.title,
      required this.user,
      required this.created_at});

  factory Ratings.fromJson(Map<String, dynamic> json) {
    return Ratings(
      user_id: json['user_id'] ?? 0,
      story_id: json['story_id'] ?? 0,
      rating: json['rating'] ?? 0,
      title: json['title'] ?? '',
      user: json['user'] != null
          ? [UserModel.fromJson(json['user'] as Map<String, dynamic>)]
          : [],
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': user_id,
      'story_id': story_id,
      'rating': rating,
      'title': title,
    };
  }
}
