import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);
  static const route = '/notification-screen';

  @override
  Widget build(BuildContext context) {
    final RemoteMessage? message =
        ModalRoute.of(context)?.settings.arguments as RemoteMessage?;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Notification'),
      ),
      body: Center(
        child: message == null
            ? const Text('No message received.')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Title: ${message.notification?.title ?? 'No Title'}'),
                  Text('Body: ${message.notification?.body ?? 'No Body'}'),
                  Text('Data: ${message.data}'),
                ],
              ),
      ),
    );
  }
}
