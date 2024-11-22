import 'package:flutter/material.dart';

Widget buildFuture<T>({
  required Future<List<T>> futureList,
  required Widget Function(BuildContext, T) itemBuilder,
  Widget? loadingWidget, // Widget tùy chỉnh khi đang load
  Widget? emptyWidget, // Widget khi không có dữ liệu
}) {
  return FutureBuilder<List<T>>(
    future: futureList,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return loadingWidget ?? Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return emptyWidget ?? Center(child: Text('No data available'));
      } else {
        final items = snapshot.data!;
        return Container(
          height: MediaQuery.of(context).size.height * 0.3,
          child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return itemBuilder(context, item);
              }),
        );
      }
    },
  );
}
