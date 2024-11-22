class Chapter {
  final int chapter_id;
  final int views;
  final String title;
  final DateTime created_at;

  Chapter({
    required this.title,
    required this.chapter_id,
    required this.views,
    required this.created_at,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      title: json['title'] ?? '',
      chapter_id: json['id'] ?? 0,
      views: json['views'] ?? 0,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }
}
