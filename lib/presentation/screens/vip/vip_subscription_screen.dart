import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:story/presentation/screens/vip/payment_web_view.dart';
import 'package:story/presentation/screens/vip/widget/vip_status_widget.dart';

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
    _getCurrentSubscription();
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

  // Future<void> fetchPackages() async {
  //   final token = await SecureTokenStorage.getToken();
  //   try {
  //     final response = await dio.get(
  //       '${ApiEndpoints.baseUrl}/api/vip/packages',
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $token',
  //         },
  //       ),
  //     );
  //     setState(() {
  //       packages = response.data['packages'];
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Không thể tải danh sách gói VIP')),
  //     );
  //   }
  // }
  //
  // Future<void> _handleSubscribe(BuildContext context, int packageId) async {
  //   try {
  //     print('Bắt đầu quá trình đăng ký gói VIP...');
  //     showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (context) => Center(child: CircularProgressIndicator()),
  //     );
  //
  //     final token = await SecureTokenStorage.getToken();
  //     print('Token đã được lấy: ${token?.substring(0, 10)}...');
  //
  //     final response = await dio.post(
  //       '${ApiEndpoints.baseUrl}/api/vip/subscribe/$packageId',
  //       options: Options(
  //         headers: {
  //           'Authorization': 'Bearer $token',
  //         },
  //       ),
  //     );
  //
  //     Navigator.pop(context); // Đóng dialog loading
  //
  //     String paymentUrl = response.data['payment_url'];
  //     print('URL thanh toán gốc: $paymentUrl');
  //
  //     // Giải mã URL
  //     paymentUrl = Uri.decodeFull(Uri.decodeFull(paymentUrl));
  //     print('URL thanh toán sau khi giải mã: $paymentUrl');
  //
  //     if (paymentUrl.isNotEmpty && Uri.parse(paymentUrl).isAbsolute) {
  //       try {
  //         final result = await Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => PaymentWebView(paymentUrl: paymentUrl),
  //           ),
  //         );
  //
  //         if (result == true) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('Thanh toán thành công'),
  //               backgroundColor: Colors.green,
  //             ),
  //           );
  //           await fetchPackages();
  //         }
  //       } catch (webViewError) {
  //         print('Lỗi khi mở WebView: $webViewError');
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text('Thanh toán không thành công'),
  //             backgroundColor: Colors.red,
  //           ),
  //         );
  //       }
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('URL thanh toán không hợp lệ')),
  //       );
  //     }
  //   } catch (e) {
  //     print('Lỗi trong quá trình xử lý: $e');
  //     Navigator.pop(context);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Có lỗi xảy ra: ${e.toString()}')),
  //     );
  //   }
  // }
  Future<void> _getCurrentSubscription() async {
    try {
      final userData = await _vipService.getCurrentUser();
      if (userData['is_vip'] && userData['current_subscription'] != null) {
        setState(() {
          currentSubscription = userData['current_subscription'];
        });
      }
    } catch (e) {
      print('Error fetching current subscription: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng ký VIP'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            fetchPackages(),
            _getCurrentSubscription(),
          ]);
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (currentSubscription != null) ...[
                Padding(
                  padding: EdgeInsets.all(16),
                  child: VipStatusWidget(
                    subscription: currentSubscription!,
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
          ),
        ),
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
