import 'user_model.dart';

class Comment {
  final String content;
  final int comment_id;
  final int parent_id;
  final int like;
  final DateTime created_at;
  final List<UserModel> user;
  final List<Comment> replies;
  Comment({
    required this.comment_id,
    required this.parent_id,
    required this.content,
    required this.like,
    required this.user,
    required this.replies,
    required this.created_at,
  });
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      comment_id: json['id'] ?? 0,
      parent_id: json['parent_id'] ?? 0,
      content: json['content'] ?? '',
      like: json['like'] ?? 0,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      user: json['user'] != null
          ? [UserModel.fromJson(json['user'] as Map<String, dynamic>)]
          : [],
      replies: json['replies'] != null
          ? (json['replies'] as List).map((i) => Comment.fromJson(i)).toList()
          : [],
    );
  }
}
