class UserVipSubscriptionModel {
  final int id;
  final SubscriptionStatus status;
  final SubscriptionDates dates;
  final SubscriptionPayment payment;

  UserVipSubscriptionModel({
    required this.id,
    required this.status,
    required this.dates,
    required this.payment,
  });

  factory UserVipSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserVipSubscriptionModel(
      id: json['id'] ?? 0,
      status: SubscriptionStatus.fromJson(json['status']),
      dates: SubscriptionDates.fromJson(json['dates']),
      payment: SubscriptionPayment.fromJson(json['payment']),
    );
  }

  bool isActive() {
    return status.isActive;
  }

  double getDaysRemaining() {
    return status.daysRemaining;
  }
}

class SubscriptionStatus {
  final bool isActive;
  final String paymentStatus;
  final double daysRemaining;

  SubscriptionStatus({
    required this.isActive,
    required this.paymentStatus,
    required this.daysRemaining,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      isActive: json['is_active'] ?? false,
      paymentStatus: json['payment_status'] ?? '',
      daysRemaining: json['days_remaining'] ?? 0.0,
    );
  }
}

class SubscriptionDates {
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionDates({
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  // Tạo factory constructor để chuyển đổi từ JSON sang object
  factory SubscriptionDates.fromJson(Map<String, dynamic> json) {
    return SubscriptionDates(
      // Sử dụng DateTime.parse để chuyển đổi chuỗi thành DateTime
      // Đồng thời cung cấp giá trị mặc định là thời điểm hiện tại nếu dữ liệu null
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : DateTime.now(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  // Thêm method để chuyển object thành JSON
  Map<String, dynamic> toJson() {
    return {
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Tiện ích để tính số ngày còn lại
  int getDaysRemaining() {
    return endDate.difference(DateTime.now()).inDays;
  }

  // Kiểm tra xem subscription có hết hạn chưa
  bool isExpired() {
    return DateTime.now().isAfter(endDate);
  }
}

class SubscriptionPayment {
  final String? transactionId; // Nullable vì có thể chưa có transaction

  SubscriptionPayment({
    this.transactionId,
  });

  factory SubscriptionPayment.fromJson(Map<String, dynamic> json) {
    return SubscriptionPayment(
      transactionId: json['transaction_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
    };
  }

  // Kiểm tra xem đã có transaction hay chưa
  bool hasTransaction() {
    return transactionId != null && transactionId!.isNotEmpty;
  }
}
