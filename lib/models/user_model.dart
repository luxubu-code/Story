class UserModel {
  final int id;
  final String name;
  final String email;
  final String image_path;
  final DateTime created_at;
  final DateTime updated_at;
  final String fcmToken;
  final String googleId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.image_path,
    required this.created_at,
    required this.updated_at,
    required this.fcmToken,
    required this.googleId,
  });

  // Phương thức để chuyển từ JSON thành model UserModel
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      image_path: json['image_path'] ?? '',
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updated_at: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      fcmToken: json['fcm_token'] ?? '',
      googleId: json['google_id'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': created_at.toIso8601String(),
      'updated_at': updated_at.toIso8601String(),
      'fcm_token': fcmToken,
      'google_id': googleId,
    };
  }
}
