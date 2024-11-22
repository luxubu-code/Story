import 'package:flutter/material.dart';

import 'AppTextStyles.dart';

Widget Settings_item_icon(IconData icon, String title) {
  return ListTile(
    leading: Icon(
      icon,
      color: Colors.black87,
    ),
    title: Text(title),
  );
}

Widget SettingsItemHozirantal(IconData icon, String title) {
  return ListTile(
    leading: Icon(
      icon,
      color: Colors.black87,
    ),
    title: Text(title),
  );
}

Widget Settings_item_horirontal(String title) {
  return Container(
    margin: EdgeInsets.only(right: 16),
    child: ListTile(
      title: Text(title),
    ),
  );
}

Widget ButtomSettings_loggout(IconData icon, String title, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.red),
        title: Text(title, style: Apptextstyles.normaltext_3_red),
      ),
    ),
  );
}
