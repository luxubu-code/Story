class Chapter {
  final int chapter_id;
  final int views;
  final String title;
  late final bool is_vip;
  final DateTime created_at;
  final DateTime vip_expiration;

  Chapter({
    required this.title,
    required this.chapter_id,
    required this.views,
    required this.is_vip,
    required this.created_at,
    required this.vip_expiration,
  });

  // Tạo đối tượng Chapter từ JSON
  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      title: json['title'] ?? '',
      chapter_id: json['id'] ?? 0,
      views: json['views'] ?? 0,
      is_vip: json['is_vip'] ?? false,
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      vip_expiration: json['vip_expiration'] != null
          ? DateTime.parse(json['vip_expiration'])
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
