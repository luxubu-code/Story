import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:story/presentation/screens/vip/payment_web_view.dart';
import 'package:story/presentation/screens/vip/widget/vip_status_widget.dart';

import '../../../core/services/provider/user_provider.dart';
import '../../../core/services/vip_service.dart';

class VipSubscriptionPage extends StatefulWidget {
  @override
  _VipSubscriptionPageState createState() => _VipSubscriptionPageState();
}

class _VipSubscriptionPageState extends State<VipSubscriptionPage> {
  // final Dio dio = Dio();
  final VipService _vipService = VipService();
  List<dynamic> packages = [];
  bool isLoading = true;
  Map<String, dynamic>? currentSubscription;

  @override
  void initState() {
    super.initState();
    fetchPackages();
    // _getCurrentSubscription();
  }

  Future<void> fetchPackages() async {
    try {
      final fetchedPackages = await _vipService.getPackages();
      setState(() {
        packages = fetchedPackages;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _handleSubscribe(BuildContext context, int packageId) async {
    try {
      // Hiển thị loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Lấy URL thanh toán
      final paymentUrl = await _vipService.subscribePackage(packageId);

      // Đóng dialog loading
      Navigator.pop(context);

      // Mở trang thanh toán
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentWebView(paymentUrl: paymentUrl),
        ),
      );

      // Xử lý kết quả thanh toán
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thanh toán thành công'),
            backgroundColor: Colors.green,
          ),
        );
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.refreshUser();
        await fetchPackages();
      }
    } catch (e) {
      Navigator.pop(context); // Đóng dialog loading nếu có lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Future<void> _getCurrentSubscription() async {
  //   try {
  //     final userData = await _vipService.getCurrentUser();
  //     if (userData['is_vip'] && userData['current_subscription'] != null) {
  //       setState(() {
  //         currentSubscription = userData['current_subscription'];
  //       });
  //     }
  //   } catch (e) {
  //     print('Error fetching current subscription: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng ký VIP'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Consumer<UserProvider>(builder: (context, userProvider, child) {
          final user = userProvider.user;
          return Column(
            children: [
              if (user != null && user.currentSubscription != null) ...[
                Padding(
                  padding: EdgeInsets.all(16),
                  child: VipStatusWidget(
                    userVipSubscriptionModel: user.currentSubscription!,
                  ),
                ),
                Divider(height: 1),
                // Padding(
                //   padding: EdgeInsets.symmetric(
                //     horizontal: 16,
                //     vertical: 12,
                //   ),
                //   child: Text(
                //     'Gia hạn gói VIP',
                //     style: Theme.of(context).textTheme.titleMedium?.copyWith(
                //           fontWeight: FontWeight.bold,
                //         ),
                //   ),
                // ),
              ],
              if (isLoading)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Đang tải danh sách gói VIP...'),
                    ],
                  ),
                )
              else if (packages.isEmpty)
                Center(
                  child: Text('Không có gói VIP nào khả dụng'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16.0),
                  itemCount: packages.length,
                  itemBuilder: (context, index) {
                    final package = packages[index];
                    return _buildPackageCard(
                      context,
                      title: package['name'] ?? 'Không có tên',
                      price: package['price'],
                      duration: '${package['duration_days']} ngày',
                      description: package['description'] ?? 'Không có mô tả',
                      onSubscribe: () =>
                          _handleSubscribe(context, package['id']),
                    );
                  },
                ),
            ],
          );
        }),
      ),
    );
  }

  final formatCurrency = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  Widget _buildPackageCard(
    BuildContext context, {
    required String title,
    required dynamic price,
    required String duration,
    required String description,
    required VoidCallback onSubscribe,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: 12),
            Text(
              'Giá: ${formatCurrency.format(double.parse(price.toString()))}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text('Thời hạn: $duration'),
            SizedBox(height: 8),
            Text('Mô tả: $description'),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubscribe,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text('Đăng ký ngay'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
