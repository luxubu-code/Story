import 'category.dart';
import 'chapter.dart';
import 'comment.dart';
import 'ratings.dart';

class Story {
  final int story_id;
  final String title;
  final String author;
  final String description;
  final int views;
  final int status;
  final int favourite;
  final String image_path;
  final DateTime created_at;
  final DateTime read_at;
  final DateTime updated_at;
  final double? averageRating;
  final List<Ratings> ratings;
  final List<Chapter> chapters;
  final List<Category> categories;
  final List<Comment> comment;

  Story(
      {required this.story_id,
      required this.title,
      required this.read_at,
      required this.updated_at,
      required this.created_at,
      required this.description,
      required this.views,
      required this.status,
      required this.favourite,
      required this.image_path,
      required this.author,
      required this.averageRating,
      required this.ratings,
      required this.chapters,
      required this.categories,
      required this.comment});

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      story_id: json['id'] ?? 0,
      title: json['title'] ?? '',
      views: json['views'] ?? 0,
      status: json['status'] ?? 1,
      favourite: json['favourite'] ?? 0,
      image_path: json['image_path'] ?? '',
      updated_at: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      read_at: json['read_at'] != null
          ? DateTime.parse(json['read_at'])
          : DateTime.now(),
      author: json['author'] ?? '',
      description: json['description'] ?? '',
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      averageRating: json['averageRating']?.toDouble(),
      chapters: json['chapter'] != null
          ? (json['chapter'] as List).map((i) => Chapter.fromJson(i)).toList()
          : [],
      categories: json['categories'] != null
          ? (json['categories'] as List)
              .map((i) => Category.fromJson(i))
              .toList()
          : [],
      ratings: json['ratings'] != null
          ? (json['ratings'] as List).map((i) => Ratings.fromJson(i)).toList()
          : [],
      comment: json['comment'] != null
          ? (json['comment'] as List).map((i) => Comment.fromJson(i)).toList()
          : [],
    );
  }

// Map<String, dynamic> toJson() {
//   return {
//     'id': story_id,
//     'title': title,
//     'author': author,
//     'description': description,
//     'views': views,
//     'base_url': base_url,
//     'file_name': file_name,
  //     'created_at': created_at.toIso8601String(),
//     'updated_at': updated_at.toIso8601String(),
//     'averageRating': averageRating,
//     'ratings': ratings.map((rating) => rating.toJson()).toList(),
//     'chapters': chapters.map((chapter) => chapter.toJson()).toList(),
//     'categories': categories.map((category) => category.toJson()).toList(),
//   };
// }
}
