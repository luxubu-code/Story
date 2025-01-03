import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/services/provider/subscription_provider.dart';
import '../../../models/vip_subscription.dart';

class SubscriptionHistoryScreen extends StatefulWidget {
  @override
  _SubscriptionHistoryScreenState createState() =>
      _SubscriptionHistoryScreenState();
}

class _SubscriptionHistoryScreenState extends State<SubscriptionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SubscriptionProvider>().fetchSubscriptions();
      context.read<SubscriptionProvider>().fetchActiveSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch sử đăng ký VIP'),
        elevation: 0,
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(provider.error!),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchSubscriptions();
                      provider.fetchActiveSubscription();
                    },
                    child: Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.activeSubscription != null)
                  _ActiveSubscriptionCard(
                    subscription: provider.activeSubscription!,
                  ),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Lịch sử đăng ký',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: provider.subscriptionHistory.length,
                  itemBuilder: (context, index) {
                    return _SubscriptionHistoryCard(
                      subscription: provider.subscriptionHistory[index],
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Widget for displaying active subscription
class _ActiveSubscriptionCard extends StatelessWidget {
  final VipSubscription subscription;

  const _ActiveSubscriptionCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Gói VIP hiện tại',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Còn ${subscription.daysRemaining} ngày',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              subscription.package['name'],
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hết hạn: ${DateFormat('dd/MM/yyyy').format(subscription.endDate)}',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget for displaying subscription history items
class _SubscriptionHistoryCard extends StatelessWidget {
  final VipSubscription subscription;

  const _SubscriptionHistoryCard({required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          subscription.package['name'],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              'Thời hạn: ${DateFormat('dd/MM/yyyy').format(subscription.startDate)} - ${DateFormat('dd/MM/yyyy').format(subscription.endDate)}',
            ),
            SizedBox(height: 4),
            Text('Trạng thái: ${subscription.status}'),
            if (subscription.vnpayTransactionId != null) ...[
              SizedBox(height: 4),
              Text('Mã giao dịch: ${subscription.vnpayTransactionId}'),
            ],
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(subscription.status),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            subscription.status,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đang hoạt động':
        return Colors.green;
      case 'Đã hết hạn':
        return Colors.grey;
      case 'Chờ thanh toán':
        return Colors.orange;
      case 'Thanh toán thất bại':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
