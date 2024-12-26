import 'package:flutter/material.dart';
import 'package:story/presentation/screens/vip/payment_webview.dart';

import '../../../core/services/subscription_service.dart';
import '../../../core/services/vip_package_service.dart';
import '../../../models/subscription.dart';
import '../../../models/vip_package.dart';

class VipPackagesScreen extends StatefulWidget {
  const VipPackagesScreen({super.key});

  @override
  State<VipPackagesScreen> createState() => _VipPackagesScreenState();
}

class _VipPackagesScreenState extends State<VipPackagesScreen> {
  final VipPackageService _packageService = VipPackageService();
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<VipPackage> _packages = [];
  Subscription? _currentSubscription;
  List<Subscription> _subscriptionHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        _packageService.getPackages(),
        _subscriptionService.getCurrentSubscription(),
        _subscriptionService.getSubscriptionHistory(),
      ]);

      setState(() {
        _packages = futures[0] as List<VipPackage>;
        _currentSubscription = futures[1] as Subscription?;
        _subscriptionHistory = futures[2] as List<Subscription>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không thể tải dữ liệu'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

// Update your _handlePurchase method
  Future<void> _handlePurchase(VipPackage package) async {
    try {
      final String paymentUrl =
          await _subscriptionService.purchaseSubscription(package.id);

      if (paymentUrl.startsWith('http')) {
        await PaymentHandler.processPayment(
          paymentUrl: paymentUrl,
          context: context,
          onPaymentComplete: () async {
            await _loadData();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thanh toán thành công!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onError: (String error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Không thể xử lý thanh toán: $error'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          },
        );
      } else {
        throw 'URL thanh toán không hợp lệ';
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể xử lý thanh toán: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _buildCurrentSubscription() {
    // Hiển thị thông báo khi chưa có gói VIP
    if (_currentSubscription == null) {
      return Card(
        margin: EdgeInsets.all(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.card_membership_outlined,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Bạn chưa có gói VIP nào',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
              SizedBox(height: 8),
              Text(
                'Hãy đăng ký gói VIP để trải nghiệm những tính năng đặc biệt',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // Hiển thị thông tin gói VIP hiện tại
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stars, color: Colors.amber),
                SizedBox(width: 8),
                Text(
                  'Gói VIP hiện tại',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Gói: ${_currentSubscription!.packageName}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 8),
            Text(
              'Trạng thái: ${_currentSubscription!.status}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Ngày bắt đầu: ${_currentSubscription!.startDate.toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8),
            Text(
              'Ngày kết thúc: ${_currentSubscription!.endDate.toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionHistory() {
    // Không hiển thị gì nếu chưa có lịch sử đăng ký
    if (_subscriptionHistory.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.history, color: Colors.grey[700]),
              SizedBox(width: 8),
              Text(
                'Lịch sử đăng ký',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _subscriptionHistory.length,
          itemBuilder: (context, index) {
            final subscription = _subscriptionHistory[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Icon(Icons.access_time, color: Colors.blueGrey),
                title: Text(
                  subscription.packageName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text('Giá: ${subscription.price.toStringAsFixed(0)}đ'),
                    Text('Trạng thái: ${subscription.status}'),
                    Text(
                        'Từ: ${subscription.startDate.toString().split(' ')[0]}'),
                    Text(
                        'Đến: ${subscription.endDate.toString().split(' ')[0]}'),
                  ],
                ),
                isThreeLine: true,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPackagesList() {
    if (_packages.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Không có gói VIP nào',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
              SizedBox(height: 8),
              Text(
                'Vui lòng thử lại sau',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      itemCount: _packages.length,
      itemBuilder: (context, index) {
        final package = _packages[index];
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  package.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 8),
                Text(
                  package.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                SizedBox(height: 12),
                Text(
                  '${package.price.toStringAsFixed(0)}đ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 12),
                Column(
                  children: package.features
                      .map((feature) => Padding(
                            padding: EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _currentSubscription != null
                        ? null
                        : () => _handlePurchase(package),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _currentSubscription != null
                          ? 'Bạn đã có gói VIP'
                          : 'Đăng ký ngay',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gói VIP'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentSubscription(),
                    _buildPackagesList(),
                    _buildSubscriptionHistory(),
                  ],
                ),
              ),
            ),
    );
  }
}

class PaymentHandler {
  // Hàm chính để xử lý thanh toán
  static Future<void> processPayment({
    required String paymentUrl,
    required VoidCallback onPaymentComplete,
    required BuildContext context,
    required Function(String) onError,
  }) async {
    try {
      // Mở trang thanh toán trong WebView
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentWebView(
              paymentUrl: paymentUrl,
              onPaymentComplete: onPaymentComplete,
              onError: onError,
            ),
          ),
        );
      }
    } catch (e) {
      onError('Không thể mở trang thanh toán: ${e.toString()}');
    }
  }
}
