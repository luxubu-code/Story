import 'package:flutter/material.dart';

class ButtonWidget {
  Widget IconButton(String text, IconData icons, VoidCallback onTap) {
    return Column(
      children: [
        GestureDetector(
          child: Icon(
            icons,
            size: 40,
            color: Colors.white,
          ),
          onTap: onTap,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          text,
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }
}
