import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentWebView extends StatefulWidget {
  final String paymentUrl;
  final VoidCallback onPaymentComplete;
  final Function(String) onError;

  const PaymentWebView({
    Key? key,
    required this.paymentUrl,
    required this.onPaymentComplete,
    required this.onError,
  }) : super(key: key);

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late WebViewController _controller;
  bool _isLoading = true;
  Timer? _checkPaymentTimer;
  static const int _checkInterval = 3; // Kiểm tra mỗi 3 giây

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.paymentUrl))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            // Bắt đầu kiểm tra trạng thái thanh toán khi trang tải xong
            _startPaymentCheck();
          },
          onNavigationRequest: (NavigationRequest request) {
            // Xử lý URL callback từ VNPay
            if (request.url.contains('vnpay/return')) {
              _handlePaymentCallback(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
  }

  void _startPaymentCheck() {
    // Hủy timer cũ nếu có
    _checkPaymentTimer?.cancel();

    // Tạo timer mới để kiểm tra định kỳ
    _checkPaymentTimer = Timer.periodic(
      Duration(seconds: _checkInterval),
      (timer) => _checkPaymentStatus(),
    );
  }

  Future<void> _checkPaymentStatus() async {
    try {
      // TODO: Thêm logic gọi API kiểm tra trạng thái thanh toán
      // Ví dụ: final status = await paymentService.checkStatus();
      // Nếu thanh toán thành công, gọi _onPaymentSuccess()
    } catch (e) {
      print('Lỗi kiểm tra trạng thái thanh toán: $e');
    }
  }

  void _handlePaymentCallback(String url) {
    // Hủy timer kiểm tra
    _checkPaymentTimer?.cancel();

    // Phân tích URL callback
    final uri = Uri.parse(url);
    final vnpResponseCode = uri.queryParameters['vnp_ResponseCode'];

    if (vnpResponseCode == '00') {
      _onPaymentSuccess();
    } else {
      widget.onError('Thanh toán không thành công');
      Navigator.of(context).pop();
    }
  }

  void _onPaymentSuccess() {
    widget.onPaymentComplete();
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _checkPaymentTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thanh toán'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
