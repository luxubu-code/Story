class Ratings {
  final int? id;
  final int? user_id;
  final int? story_id;
  final int rating;
  final DateTime created_at;
  Ratings(
      {required this.id,
      required this.user_id,
      required this.story_id,
      required this.rating,
      required this.created_at});
  factory Ratings.fromJson(Map<String, dynamic> json) {
    return Ratings(
      id: json['id'] ?? 0,
      user_id: json['user_id'] ?? 0,
      story_id: json['story_id'] ?? 0,
      rating: json['rating'] ?? 0,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': user_id,
      'story_id': story_id,
      'rating': rating,
    };
  }
}
