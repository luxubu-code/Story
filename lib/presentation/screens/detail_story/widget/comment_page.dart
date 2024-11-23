import 'package:flutter/material.dart';

import '../../../../core/services/story_service.dart';
import '../../../../core/utils/future_widget.dart';
import '../../../../models/comment.dart';
import 'comment_widget.dart';

class CommentPage extends StatefulWidget {
  final int story_id;

  const CommentPage({super.key, required this.story_id});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  late Future<List<Comment>> _futureComments;
  late TextEditingController _commentController = TextEditingController();
  final StoryService _storyService = StoryService();

  @override
  void initState() {
    super.initState();
    _loadComment();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _loadComment() {
    _futureComments = _storyService.fetchComment(widget.story_id);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      builder: (context, controller) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Thanh tiêu đề
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.arrow_back_ios_new_outlined,
                        color: Colors.grey.shade700,
                        size: 24,
                      ),
                    ),
                    Text(
                      'Bình luận',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 24), // Để cân bằng hai bên
                  ],
                ),
              ),
              const Divider(thickness: 1),
              Expanded(
                child: buildFuture(
                  futureList: _futureComments,
                  itemBuilder: (context, comment) => CommentWidget(
                    comment: comment,
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCommentInput(),
                    ),
                    const SizedBox(width: 10),
                    _buildSendButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.grey[100], // Màu nền nhẹ hơn
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _commentController,
        decoration: const InputDecoration(
          hintText: 'Viết bình luận...',
          border: InputBorder.none,
          hintStyle:
              TextStyle(color: Colors.grey), // Màu chữ gợi ý nhẹ nhàng hơn
        ),
        style: const TextStyle(fontSize: 16, color: Colors.black),
      ),
    );
  }

  void showComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CommentPage(story_id: widget.story_id);
      },
    );
  }

  Widget _buildSendButton() {
    return GestureDetector(
      onTap: () async {
        if (_commentController.text.isNotEmpty) {
          bool success = await _storyService.postComment(
              widget.story_id, null, _commentController.text);
          if (success) {
            _commentController.clear();
            setState(() {
              _loadComment();
            });
            Navigator.pop(context); // Đóng modal hiện tại
            showComments();
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Colors.pinkAccent, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(Icons.send, color: Colors.white),
      ),
    );
  }
}