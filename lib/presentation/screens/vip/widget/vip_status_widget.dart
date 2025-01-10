import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../models/user_vip_subscription_model.dart';

class VipStatusWidget extends StatelessWidget {
  final UserVipSubscriptionModel userVipSubscriptionModel;

  const VipStatusWidget({
    Key? key,
    required this.userVipSubscriptionModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = userVipSubscriptionModel.status;
    final dates = userVipSubscriptionModel.dates;

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final startDate = DateTime.parse(dates.startDate.toString());
    final endDate = DateTime.parse(dates.endDate.toString());

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stars, color: Colors.amber),
              SizedBox(width: 8),
              Text(
                'Bạn đang là thành viên VIP',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildInfoRow(
            'Thời gian bắt đầu:',
            dateFormat.format(startDate),
          ),
          SizedBox(height: 4),
          _buildInfoRow(
            'Thời gian kết thúc:',
            dateFormat.format(endDate),
          ),
          SizedBox(height: 4),
          _buildInfoRow(
            'Số ngày còn lại:',
            '${status.daysRemaining.toStringAsFixed(1)} ngày',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade900,
          ),
        ),
      ],
    );
  }
}
