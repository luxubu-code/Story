import 'package:flutter/material.dart';

import '../../../../core/utils/dateTimeFormatUtils.dart';
import '../../../../models/comment.dart';

class CommentWidget extends StatelessWidget {
  final Comment comment;

  const CommentWidget({Key? key, required this.comment}) : super(key: key);

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
                  backgroundImage: comment.user[0].image_path == null
                      ? NetworkImage(comment.user[0].image_path!)
                      : AssetImage('assets/avatar.png') as ImageProvider,
                  radius: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.user[0].name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        comment.content,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        time(comment.created_at),
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
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Nút thích bình luận
                GestureDetector(
                  onTap: () async {
                    // Gọi API để tăng lượt like của bình luận
                    // bool success = await _storyService.likeComment(comment.parent_id);
                    // if (success) {
                    //   setState(() {
                    //     comment.like += 1; // Cập nhật số lượt like
                    //   });
                    // }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.white70, size: 18),
                      SizedBox(width: 4),
                      Text('${comment.like}',
                          style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                // Nút trả lời bình luận
                SizedBox(
                  width: 30,
                ),
                GestureDetector(
                  onTap: () {
                    _showReplyInput(
                        comment.parent_id, context); // Gọi hàm mở modal trả lời
                  },
                  child: Text(
                    'Trả lời',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
            if (comment.replies != null && comment.replies!.isNotEmpty) ...[
              SizedBox(height: 8),
              // Danh sách các câu trả lời của bình luận
              ...comment.replies!.map((reply) => _buildReply(reply)).toList(),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildReply(Comment reply) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0, top: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundImage: reply.user[0].image_path != null
                  ? NetworkImage(reply.user[0].image_path!)
                  : AssetImage('assets/avatar.png') as ImageProvider,
              radius: 18,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reply.user[0].name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    reply.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReplyInput(int commentId, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        TextEditingController _replyController = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _replyController,
                  decoration: InputDecoration(
                    hintText: 'Viết câu trả lời...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    // if (_replyController.text.isNotEmpty) {
                    //   bool success = await _storyService.postReply(
                    //       commentId, _replyController.text);
                    //   if (success) {
                    //     setState(() {
                    //       _loadComment(); // Load lại bình luận và câu trả lời mới
                    //     });
                    //     Navigator.pop(context); // Đóng modal
                    //   }
                    // }
                  },
                  child: Text('Gửi'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
