import 'package:flutter/material.dart';
import 'package:story/core/services/rating_service.dart';
import 'package:story/models/ratings.dart';

import '../../../../core/utils/dateTimeFormatUtils.dart';

class RatingsWidget extends StatefulWidget {
  final int story_id;
  final Ratings ratings;
  final bool isMyRating;
  final VoidCallback onRatingDeleted;

  const RatingsWidget(
      {super.key,
      required this.story_id,
      required this.ratings,
      required this.isMyRating,
      required this.onRatingDeleted});

  @override
  State<RatingsWidget> createState() => _RatingsWidget();
}

class _RatingsWidget extends State<RatingsWidget> {
  final RatingService _commentService = RatingService();

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
                  backgroundImage: widget.ratings.user[0].avatar_url != ''
                      ? NetworkImage(widget.ratings.user[0].avatar_url)
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
                          widget.ratings.rating,
                          (index) => Icon(
                            Icons.star,
                            color: index < widget.ratings.rating
                                ? Colors.yellow
                                : Colors.white70,
                            size: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 4),
                      // Tên người dùng
                      Text(
                        widget.ratings.user[0].name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      // Tiêu đề đánh giá
                      Text(
                        widget.ratings.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Thời gian tạo
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            time(widget.ratings.created_at),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          if (widget.isMyRating)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    // Hiển thị hộp thoại xác nhận
                                    bool? confirmDelete =
                                        await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Xóa đánh giá'),
                                        content: Text(
                                            'Bạn có chắc chắn muốn xóa đánh giá này?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: Text('Hủy'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: Text('Xóa'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirmDelete == true) {
                                      try {
                                        bool? success =
                                            await _commentService.deleteRating(
                                                widget.ratings.user[0].id,
                                                context);
                                        if (success) {
                                          widget.onRatingDeleted();
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content:
                                                    Text('Đã xóa đánh giá')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Không thể xóa đánh giá')),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content:
                                                  Text('Đã xảy ra lỗi: $e')),
                                        );
                                      }
                                    }
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete,
                                          color: Colors.red, size: 18),
                                      SizedBox(width: 4),
                                      Text(
                                        'Xóa',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                        ],
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
