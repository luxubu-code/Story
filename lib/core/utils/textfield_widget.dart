import 'package:flutter/material.dart';

Widget textfield_widget(
    TextEditingController controller, Icon icon, String text) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      prefixIcon: icon,
      labelText: text,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    //obscureText: true,
  );
}
