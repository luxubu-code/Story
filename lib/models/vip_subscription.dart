class VipSubscription {
  final int id;
  final Map<String, dynamic> package;
  final DateTime startDate;
  final DateTime endDate;
  final String? paymentStatus;
  final String? vnpayTransactionId;
  final int isActive;
  final int daysRemaining;
  final String status;

  VipSubscription({
    required this.id,
    required this.package,
    required this.startDate,
    required this.endDate,
    required this.paymentStatus,
    this.vnpayTransactionId,
    required this.isActive,
    required this.daysRemaining,
    required this.status,
  });

  factory VipSubscription.fromJson(Map<String, dynamic> json) {
    int convertDaysRemaining(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.round(); // Rounds to nearest integer
      if (value is String) {
        try {
          return double.parse(value).round();
        } catch (_) {
          return 0;
        }
      }
      return 0; // Default value if conversion fails
    }

    return VipSubscription(
      id: json['id'] ?? 0,
      package: json['package'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      paymentStatus: json['payment_status'] ?? '',
      vnpayTransactionId: json['vnpay_transaction_id'] ?? '',
      isActive: json['is_active'] ?? 0,
      daysRemaining: convertDaysRemaining(json['days_remaining']),
      status: json['status'] ?? '',
    );
  }
}
