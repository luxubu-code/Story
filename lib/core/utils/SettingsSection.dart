import 'package:flutter/material.dart';

Widget SettingsSection(List<Widget> items) {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1)
        ]),
    child: Column(
      children: items,
    ),
  );
}

Widget buildHorizontalList(List<Widget> items) {
  return Container(
    height: 100,
    width: 100,
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1)
        ]),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items,
      ),
    ),
  );
}
// Center(
// child: ListTile(
// title: Text('ccccccc'),
// onTap: () {},
// ),
// ),
