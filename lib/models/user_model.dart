class UserModel {
  final int id;
  final String name;
  final String email;
  final String avatar_url;
  final DateTime created_at;
  final String date_of_birth;
  final String? fcmToken; // Made optional
  final String? googleId; // Made optional

  UserModel({
    this.id = 0, // Provided default value since it's not in response
    required this.name,
    required this.email,
    required this.avatar_url,
    required this.created_at,
    required this.date_of_birth,
    this.fcmToken,
    this.googleId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      avatar_url: json['avatar_url'] ?? '',
      created_at: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      date_of_birth: json['date_of_birth'] ?? '',
      fcmToken: json['fcm_token'],
      googleId: json['google_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': created_at.toIso8601String(),
      'fcm_token': fcmToken,
      'google_id': googleId,
    };
  }
}
