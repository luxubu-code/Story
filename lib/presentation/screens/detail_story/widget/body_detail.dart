import 'package:flutter/material.dart';

import '../../../../core/services/story_service.dart';
import '../../../../core/utils/future_widget.dart';
import '../../../../models/category.dart';
import '../../../../models/comment.dart';
import '../../../widgets/show_more.dart';
import 'comment_page.dart';
import 'comment_widget.dart';
import 'expandable_text.dart';
import 'story_category.dart';

class BodyDetail extends StatefulWidget {
  final int story_id;
  final int status;
  final List<Category> categories;
  final String description;

  const BodyDetail({
    super.key,
    required this.categories,
    required this.description,
    required this.status,
    required this.story_id,
  });

  @override
  State<BodyDetail> createState() => _BodyDetailState();
}

class _BodyDetailState extends State<BodyDetail> {
  late Future<List<Comment>> _futureComment;
  final StoryService _storyService = StoryService();
  late CommentPage commentPage = CommentPage(story_id: widget.story_id);

  @override
  void initState() {
    super.initState();
    _loadComment();
  }

  void _loadComment() {
    _futureComment = _storyService.fetchMostLikesComment(1, widget.story_id);
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CategoryWidget(widget.categories),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Status : ${widget.status == 1 ? 'Đang ra' : 'Hoàn Thành'}',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.black,
                    overflow: TextOverflow.fade),
              ),
            ),
            ExpandableText(description: widget.description),
            ShowMore(
              title: 'Bình Luận Nổi Bật',
              onShowMore: showComments,
              border: false,
            ),
            buildFuture(
              futureList: _futureComment,
              itemBuilder: (context, comment) =>
                  CommentWidget(comment: comment),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              child: Text(
                'Read Comic',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
