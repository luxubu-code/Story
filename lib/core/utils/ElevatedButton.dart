import 'package:flutter/material.dart';

Widget Elevated_Buttom_Setting(String text) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.only(right: 4),
      child: ElevatedButton(
        onPressed: () {},
        child: Text(
          text,
          style: TextStyle(fontSize: 10),
          maxLines: 1,
          overflow: TextOverflow.fade,
        ),
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            shadowColor: Colors.black,
            foregroundColor: Colors.pink,
            backgroundColor: Colors.pink[100],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50))),
      ),
    ),
  );
}

Widget ElevatedButtom_item_icon(IconData icon, String title, VoidCallback cc) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: ElevatedButton(
      onPressed: cc,
      child: ListTile(
        leading: Padding(
          padding: const EdgeInsets.only(right: 30.0),
          child: Icon(
            icon,
            color: Colors.black87,
          ),
        ),
        title: Text(
          title,
          maxLines: 1,
          style: TextStyle(
            overflow: TextOverflow.fade,
          ),
        ),
      ),
    ),
  );
}
