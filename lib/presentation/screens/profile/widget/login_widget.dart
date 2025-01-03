import 'package:flutter/material.dart';
import 'package:story/core/utils/navigation_utils.dart';

import '../../login/login_screen.dart';

Widget login_widget(BuildContext context) {
  return GestureDetector(
    onTap: () => NavigationUtils.navigateTo(context, LoginScreen()),
    child: Row(
      children: [
        CircleAvatar(
          radius: 35,
          backgroundColor: Colors.purpleAccent.withOpacity(0.7),
          child: Icon(
            Icons.person_outline,
            size: 40,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ấn để đăng nhập',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.pinkAccent.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Khách',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
