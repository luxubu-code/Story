import 'package:story/models/vip_package.dart';

class Subscription {
  final int? id; // Cho phép null
  final int? userId; // Cho phép null
  final int? vipPackageId; // Cho phép null
  final String packageName;
  final int packageDuration;
  final double price;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final VipPackage? package;

  Subscription({
    this.id, // Không bắt buộc
    this.userId, // Không bắt buộc
    this.vipPackageId, // Không bắt buộc
    required this.packageName,
    required this.packageDuration,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.package,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    // Hàm hỗ trợ parse DateTime an toàn
    DateTime parseDateTime(String? dateString) {
      if (dateString == null) return DateTime.now();
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        print('Lỗi parse ngày: $e');
        return DateTime.now();
      }
    }

    // Hàm hỗ trợ parse số an toàn
    double parsePrice(dynamic price) {
      if (price == null) return 0.0;
      if (price is int) return price.toDouble();
      if (price is double) return price;
      if (price is String) return double.tryParse(price) ?? 0.0;
      return 0.0;
    }

    return Subscription(
      id: json['id'] as int?,
      // Chấp nhận null
      userId: json['user_id'] as int?,
      // Chấp nhận null
      vipPackageId: json['vip_package_id'] as int?,
      // Chấp nhận null
      packageName: json['package_name'] ?? 'Không xác định',
      packageDuration: json['package_duration'] ?? 0,
      price: parsePrice(json['price']),
      startDate: parseDateTime(json['start_date']),
      endDate: parseDateTime(json['end_date']),
      status: json['status'] ?? 'unknown',
      package:
          json['package'] != null ? VipPackage.fromJson(json['package']) : null,
    );
  }
}
