import 'package:flutter/material.dart';

class ShowMore extends StatelessWidget {
  final String title;
  final VoidCallback onShowMore;
  final bool border;

  const ShowMore({
    Key? key,
    required this.title,
    required this.onShowMore,
    required this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: border
            ? const Border.symmetric(
                horizontal: BorderSide(color: Colors.purpleAccent))
            : Border.all(color: Colors.transparent),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.fade,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          TextButton(
            onPressed: onShowMore, // Sử dụng callback khi nhấn nút
            child: const Row(
              children: [
                Text('show more'),
                Icon(Icons.navigate_next),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
