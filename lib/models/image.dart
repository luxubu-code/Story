class ImagePath {
  final int id_story;
  final int id_chapter;
  final String base_url;
  final String file_name;

  ImagePath({
    required this.id_story,
    required this.base_url,
    required this.file_name,
    required this.id_chapter,
  });

  factory ImagePath.fromJson(Map<String, dynamic> json) {
    return ImagePath(
        id_story: json['id_story'] ?? 0,
        base_url: json['base_url'] ?? '',
        file_name: json['file_name'] ?? '',
        id_chapter: json['id_chapter'] ?? 0);
  }
}
