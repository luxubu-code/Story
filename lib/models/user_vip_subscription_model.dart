class UserVipSubscriptionModel {
  final int id;
  final int vipPackageId;
  final DateTime startDate;
  final DateTime endDate;
  final String paymentStatus;
  final String? vnpayTransactionId;

  UserVipSubscriptionModel({
    required this.id,
    required this.vipPackageId,
    required this.startDate,
    required this.endDate,
    required this.paymentStatus,
    this.vnpayTransactionId,
  });

  factory UserVipSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return UserVipSubscriptionModel(
      id: json['id'] ?? 0,
      vipPackageId: json['vip_package_id'] ?? 0,
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : DateTime.now(),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : DateTime.now(),
      paymentStatus: json['payment_status'] ?? '',
      vnpayTransactionId: json['vnpay_transaction_id'],
    );
  }

  // Kiểm tra xem subscription có đang active không
  bool isActive() {
    return paymentStatus == 'completed' && endDate.isAfter(DateTime.now());
  }

  // Lấy số ngày còn lại của subscription
  int getDaysRemaining() {
    if (!isActive()) return 0;
    return endDate.difference(DateTime.now()).inDays;
  }
}
