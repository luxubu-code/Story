import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget buildShimmerLoading() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 150.0,
          color: Colors.white,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
        ),
        Container(
          width: double.infinity,
          height: 15.0,
          color: Colors.white,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
        ),
        Container(
          width: 200.0,
          height: 15.0,
          color: Colors.white,
        ),
      ],
    ),
  );
}
