import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/core/constants/AppColors.dart';
import 'package:story/core/services/comment_service.dart';

import '../../../../core/services/provider/auth_provider_check.dart';
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
  final CommentService _commentService = CommentService();
  late CommentPage commentPage = CommentPage(story_id: widget.story_id);

  @override
  void initState() {
    super.initState();
    _loadComment();
  }

  void _refreshComments() {
    setState(() {
      _futureComment =
          _commentService.fetchMostLikesComment(1, widget.story_id, context);
    });
  }

  void _loadComment() {
    _futureComment =
        _commentService.fetchMostLikesComment(1, widget.story_id, context);
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
    final authProvider = Provider.of<AuthProviderCheck>(context, listen: false);

    return SingleChildScrollView(
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CategoryWidget(widget.categories),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    text: TextSpan(
                      text: 'Status : ', // Phần này không đổi màu
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(
                          text: widget.status == 1 ? 'Hoàn Thành' : 'Đang ra',
                          style: TextStyle(
                            color: widget.status == 1
                                ? AppColors.cornflowerBlue
                                : AppColors.magentaPurple,
                            fontWeight: FontWeight
                                .bold, // Tùy chọn in đậm cho trạng thái
                          ),
                        ),
                      ],
                    ),
                  )),
              ExpandableText(description: widget.description),
              ShowMore(
                title: 'Bình Luận Nổi Bật',
                onShowMore: showComments,
                border: false,
              ),
              buildFuture(
                futureList: _futureComment,
                itemBuilder: (context, comment) => CommentWidget(
                  comment: comment,
                  isMyComment:
                      authProvider.currentUser?.id == comment.user[0].id,
                  onCommentDeleted: _refreshComments,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
