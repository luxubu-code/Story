class VipPackage {
  final int id;
  final String name;
  final int duration;
  final double price;
  final String description;
  final List<String> features;
  final DateTime createdAt;
  final DateTime updatedAt;

  VipPackage({
    required this.id,
    required this.name,
    required this.duration,
    required this.price,
    required this.description,
    required this.features,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VipPackage.fromJson(Map<String, dynamic> json) {
    return VipPackage(
      id: json['id'],
      name: json['name'],
      duration: json['duration'],
      price: double.parse(json['price']),
      description: json['description'],
      features: List<String>.from(json['features']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
