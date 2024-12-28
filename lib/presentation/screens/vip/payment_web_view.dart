import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;

  const PaymentWebView({Key? key, required this.paymentUrl}) : super(key: key);

  @override
  _PaymentWebViewState createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    print('PaymentWebView: initState được gọi');
    print('URL cần tải: ${widget.paymentUrl}');

    try {
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              print('WebView: Bắt đầu tải trang - $url');
              setState(() {
                isLoading = true;
                hasError = false;
              });
            },
            onPageFinished: (String url) {
              print('WebView: Tải trang hoàn tất - $url');
              setState(() {
                isLoading = false;
              });

              // Phân tích URL trả về từ VNPAY
              if (url.contains('/api/vnpay/return')) {
                final uri = Uri.parse(url);
                final responseCode = uri.queryParameters['vnp_ResponseCode'];

                if (responseCode == '00') {
                  // Thanh toán thành công
                  print(
                      'Thanh toán thành công - Transaction ID: ${uri.queryParameters['vnp_TransactionNo']}');
                  Navigator.of(context).pop(true);
                } else {
                  // Thanh toán thất bại
                  setState(() {
                    hasError = true;
                    errorMessage =
                        'Thanh toán thất bại: ${uri.queryParameters['vnp_OrderInfo']}';
                  });
                  Future.delayed(Duration(seconds: 2), () {
                    Navigator.of(context).pop(false);
                  });
                }
              }
            },
            onWebResourceError: (WebResourceError error) {
              print('WebView Error: ${error.description}');
              print('Error Code: ${error.errorCode}');
              print('Error Type: ${error.errorType}');
              print('Failed URL: ${error.url}');
              setState(() {
                hasError = true;
                errorMessage = 'Lỗi kết nối: ${error.description}';
                isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lỗi tải trang: ${error.description}')),
              );
            },
          ),
        )
        ..loadRequest(Uri.parse(widget.paymentUrl));
      print('WebViewController đã được khởi tạo thành công');
    } catch (e) {
      print('Lỗi khởi tạo WebView: $e');
      setState(() {
        hasError = true;
        errorMessage = 'Không thể khởi tạo trang thanh toán';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thanh toán VNPay'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Stack(
        children: [
          if (!hasError) WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải trang thanh toán...'),
                ],
              ),
            ),
          if (hasError)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 48),
                    SizedBox(height: 16),
                    Text(
                      errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red),
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Quay lại'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
