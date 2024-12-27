import 'package:flutter/material.dart';

import '../../main.dart';

class NavigationUtils {
  static void goBack(BuildContext context) {
    Navigator.pop(context);
  }

  static void navigateTo(BuildContext context, Widget widget) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => widget,
        ));
  }

  static void navigateReplacement(BuildContext context, Widget widget) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => widget,
        ));
  }

  static void navigateWithBottom(BuildContext context, Widget widget) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MyHomePage(
          initialIndex: 2,
        ),
      ),
    );
  }
}
