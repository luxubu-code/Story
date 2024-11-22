import 'package:flutter/material.dart';

extension ResizableWidget on Widget {
  Widget setSize(
      {double? width, double? height, double? fontSize, double? iconSize}) {
    if (this is Text) {
      return Text(
        (this as Text).data ?? '',
        style: (this as Text).style?.copyWith(fontSize: fontSize) ??
            TextStyle(fontSize: fontSize),
      );
    } else if (this is Icon) {
      return Icon(
        (this as Icon).icon,
        size: iconSize ?? (this as Icon).size,
        color: (this as Icon).color,
      );
    } else {
      return Container(
        width: width,
        height: height,
        child: this,
      );
    }
  }
}
