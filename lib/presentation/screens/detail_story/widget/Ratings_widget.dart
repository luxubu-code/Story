import 'package:flutter/material.dart';
import 'package:story/models/ratings.dart';

import '../../../../core/utils/dateTimeFormatUtils.dart';

class RatingsWidget extends StatelessWidget {
  final int story_id;
  final Ratings ratings;

  const RatingsWidget(
      {super.key, required this.story_id, required this.ratings});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.pinkAccent.shade100, Colors.purpleAccent.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundImage: ratings.user[0].avatar_url != ''
                      ? NetworkImage(ratings.user[0].avatar_url)
                      : AssetImage('assets/avatar.png') as ImageProvider,
                  radius: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hàng hiển thị số sao
                      Row(
                        children: List.generate(
                          ratings.rating,
                          (index) => Icon(
                            Icons.star,
                            color: index < ratings.rating
                                ? Colors.yellow
                                : Colors.white70,
                            size: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      // Tên người dùng
                      Text(
                        ratings.user[0].name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      // Tiêu đề đánh giá
                      Text(
                        ratings.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Thời gian tạo
                      Text(
                        time(ratings.created_at),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
