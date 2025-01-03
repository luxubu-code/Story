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

  // Tạo đối tượng Chapter từ JSON
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

  // Chuyển Chapter thành JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'id': chapter_id,
      'views': views,
      'created_at': created_at.toIso8601String(),
    };
  }
}
