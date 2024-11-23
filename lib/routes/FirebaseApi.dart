import 'package:firebase_messaging/firebase_messaging.dart';

import '../core/services/auth_service.dart';
import '../main.dart';
import 'notification_screen.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  bool _isRequestingPermission = false; // Biến cờ

  void handleMessage(RemoteMessage? message) {
    if (message == null) return;
    navigatorKey.currentState?.pushNamed(
      NotificationScreen.route,
      arguments: message,
    );
  }

  Future<void> initPushNotifications() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }

  Future<void> initNotifications() async {
    if (_isRequestingPermission) return; // Nếu đang yêu cầu, thoát
    _isRequestingPermission = true;

    try {
      await _firebaseMessaging.requestPermission();
      final fcmToken = await _firebaseMessaging.getToken();
      if (fcmToken != null) {
        await AuthService.sendFcm(fcmToken);
        print('FCM Token: $fcmToken');
      } else {
        print('Failed to obtain FCM Token');
      }
      await initPushNotifications();
    } catch (e) {
      print('Error in requesting permission: $e');
    } finally {
      _isRequestingPermission = false; // Đặt lại biến cờ
    }
  }
}
