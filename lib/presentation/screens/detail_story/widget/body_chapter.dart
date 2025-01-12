import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/core/services/history_service.dart';
import 'package:story/core/utils/navigation_utils.dart';
import 'package:story/presentation/screens/login/login_screen.dart';

import '../../../../core/services/provider/auth_provider_check.dart';
import '../../../../core/utils/countdown_time.dart';
import '../../../../core/utils/dateTimeFormatUtils.dart';
import '../../../../models/chapter.dart';
import '../../chapter/chapter_screen.dart';
import '../../vip/vip_subscription_screen.dart';

class BodyChapter extends StatefulWidget {
  final List<Chapter> chapters;
  final int story_id;
  final bool storyVip;
  final VoidCallback? function;

  const BodyChapter({
    super.key,
    required this.chapters,
    required this.story_id,
    required this.storyVip,
    this.function,
  });

  @override
  State<BodyChapter> createState() => _BodyChapterState();
}

class _BodyChapterState extends State<BodyChapter> {
  final HistoryService historyService = HistoryService();

// chương vip thì phải kiểm tra đăng nhập sau đó kiểm tra vip mới đọc được
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: ListView.separated(
        padding: const EdgeInsets.all(10.0),
        itemCount: widget.chapters.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final chapter = widget.chapters[index];
          return GestureDetector(
            onTap: () {
              final authProvider =
                  Provider.of<AuthProviderCheck>(context, listen: false);
              if (chapter.is_vip) {
                if (!authProvider.isLoggedIn) {
                  NavigationUtils.navigateTo(context, LoginScreen());
                } else if (!authProvider.currentUser!.isVip) {
                  NavigationUtils.navigateTo(context, VipSubscriptionPage());
                } else {
                  historyService.postHistory(
                      widget.story_id, chapter.chapter_id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChapterScreen(
                        chapter_id: chapter.chapter_id,
                        chapters: widget.chapters,
                        story_id: widget.story_id,
                      ),
                    ),
                  );
                }
              } else {
                if (authProvider.isLoggedIn) {
                  historyService.postHistory(
                      widget.story_id, chapter.chapter_id);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChapterScreen(
                        chapter_id: chapter.chapter_id,
                        chapters: widget.chapters,
                        story_id: widget.story_id,
                      ),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChapterScreen(
                        chapter_id: chapter.chapter_id,
                        chapters: widget.chapters,
                        story_id: widget.story_id,
                      ),
                    ),
                  );
                }
              }
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2), // Đổ bóng nhẹ
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3), // Đổ bóng xuống dưới
                  ),
                ],
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFe0c3fc),
                    Color(0xFF8ec5fc)
                  ], // Gradient pastel nhẹ
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Book Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.book,
                              color: Colors.white
                                  .withOpacity(0.9), // Icon màu trắng mờ
                            ),
                            const SizedBox(width: 10),
                            Text(
                              chapter.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Chữ màu trắng
                              ),
                            ),
                          ],
                        ),
                        _buildChapterStatusIcon(chapter, chapter.vip_expiration)
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          time(chapter.created_at),
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.remove_red_eye_outlined,
                              size: 16,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              chapter.views.toString(),
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChapterStatusIcon(Chapter chapter, DateTime vip_expiration) {
    if (chapter.is_vip == true && widget.storyVip) {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: CountdownTime(
              time: vip_expiration,
              textStyle: TextStyle(color: Colors.white),
              function: () {
                // Gọi refresh ở đây
                widget.function?.call();
              },
            ),
          ),
          Icon(
            Icons.lock,
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),
        ],
      );
    } else if (chapter.is_vip == false && widget.storyVip) {
      return Icon(
        Icons.lock_open,
        color: Colors.white.withOpacity(0.7),
        size: 20,
      );
    }
    return const SizedBox.shrink();
  }
}
