import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:story/core/services/image_service.dart';

import '../../../core/services/history_service.dart';
import '../../../models/chapter.dart';
import '../../../models/image.dart';
import '../detail_story/widget/comment_page.dart';
import 'chapter_bottom_sheet.dart';

class ChapterScreen extends StatefulWidget {
  final List<Chapter> chapters;
  final int chapter_id;
  final int story_id;

  const ChapterScreen({
    super.key,
    required this.chapter_id,
    required this.chapters,
    required this.story_id,
  });

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  late Future<List<ImagePath>> images;
  final ImageService imageService = ImageService();
  late ScrollController _scrollController;
  final HistoryService historyService = HistoryService();

  bool _isBottomVisible = true; // Đảm bảo tên biến này đúng

  @override
  void initState() {
    super.initState();
    images = imageService.fetchImage(widget.chapter_id);
    _scrollController = ScrollController();
    _scrollController.addListener(
      () {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          setState(() {
            _isBottomVisible = false;
          });
        } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward) {
          setState(() {
            _isBottomVisible = true;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
    return Scaffold(
      body: Stack(
        children: [
          FutureBuilder<List<ImagePath>>(
            future: images,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No images found.'));
              } else {
                return CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    SliverAppBar(
                      automaticallyImplyLeading: false,
                      // Loại bỏ nút quay lại
                      leading: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back_sharp)),
                      title: Text('Example'),
                      floating: true,
                      snap: true,
                      shape: StadiumBorder(
                        side: BorderSide(color: Colors.white, width: 2.0),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final imagePath = snapshot.data![index];
                          return Container(
                            child: Image.network(
                                imagePath.base_url + imagePath.file_name),
                          );
                        },
                        childCount: snapshot.data!.length,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
          if (_isBottomVisible)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 70,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withOpacity(0.9), // Thay đổi độ trong suốt ở đây
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, -1),
                    ),
                  ],
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBottomBarItem(
                      icon: Icons.arrow_back,
                      label: 'Previous',
                      onPressed: () {
                        int currentIndex = widget.chapters.indexWhere(
                            (chapter) =>
                                chapter.chapter_id == widget.chapter_id);
                        if (currentIndex > 0) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChapterScreen(
                                  chapter_id: widget
                                      .chapters[currentIndex - 1].chapter_id,
                                  chapters: widget.chapters,
                                  story_id: widget.story_id,
                                ),
                              ));
                        }
                      },
                    ),
                    _buildBottomBarItem(
                      icon: Icons.list_alt_sharp,
                      label: 'List Chapter',
                      onPressed: () {
                        historyService.postHistory(
                            widget.story_id, widget.chapter_id);

                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) {
                            return ChapterBottomSheet(
                              chapters: widget.chapters,
                              storyId: widget.story_id,
                              currentChapter: widget.chapter_id,
                            );
                          },
                        );
                      },
                    ),
                    _buildBottomBarItem(
                      icon: Icons.comment,
                      label: 'Comment',
                      onPressed: showComments,
                    ),
                    _buildBottomBarItem(
                      icon: Icons.arrow_forward,
                      label: 'Next',
                      onPressed: () {
                        int currentIndex = widget.chapters.indexWhere(
                            (chapter) =>
                                chapter.chapter_id == widget.chapter_id);
                        int maxLengthIndex = widget.chapters.length - 1;
                        if (currentIndex < maxLengthIndex) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChapterScreen(
                                  chapter_id: widget
                                      .chapters[currentIndex + 1].chapter_id,
                                  chapters: widget.chapters,
                                  story_id: widget.story_id,
                                ),
                              ));
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBarItem({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.black54),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
