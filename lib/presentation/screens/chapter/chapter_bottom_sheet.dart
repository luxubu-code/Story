import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story/core/constants/AppColors.dart';

import '../../../../models/chapter.dart';
import '../../../core/services/history_service.dart';
import '../../../core/services/provider/auth_provider_check.dart';
import '../../../core/utils/navigation_utils.dart';
import '../login/login_screen.dart';
import '../vip/vip_subscription_screen.dart';
import 'chapter_screen.dart';

class ChapterBottomSheet extends StatelessWidget {
  final List<Chapter> chapters;
  final int storyId;
  final int currentChapter;

  const ChapterBottomSheet({
    super.key,
    required this.chapters,
    required this.storyId,
    required this.currentChapter,
  });

  @override
  Widget build(BuildContext context) {
    void handleChapterNavigation(Chapter chapter) {
      final authProvider =
          Provider.of<AuthProviderCheck>(context, listen: false);

      // Xử lý logic cho chapter VIP
      if (chapter.is_vip) {
        if (!authProvider.isLoggedIn) {
          NavigationUtils.navigateTo(context, LoginScreen());
          return;
        }

        if (!authProvider.currentUser!.isVip) {
          NavigationUtils.navigateTo(context, VipSubscriptionPage());
          return;
        }
      }

      // Ghi lại lịch sử nếu user đã đăng nhập
      if (authProvider.isLoggedIn) {
        HistoryService().postHistory(storyId, chapter.chapter_id);
      }
      Navigator.pop(context);
      // Chuyển đến chapter mới
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChapterScreen(
            chapter_id: chapter.chapter_id,
            chapters: chapters,
            story_id: storyId,
          ),
        ),
      );
      // // Chuyển đến chapter mới và xóa hết lịch sử điều hướng đến chapter cũ
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => ChapterScreen(
      //       chapter_id: chapter.chapter_id,
      //       chapters: chapters,
      //       story_id: storyId,
      //     ),
      //   ),
      //       (route) {
      //     // Kiểm tra nếu route hiện tại là ChapterScreen
      //     return route.settings.name != null &&
      //         !route.settings.name!.startsWith('/chapter');
      //   },
      // );
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        gradient: LinearGradient(
          colors: [
            Colors.purple.shade100.withOpacity(0.8),
            Colors.blue.shade200.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              width: 50,
              height: 6,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(3),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Text(
                'Danh sách chương',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 1.1,
                ),
              ),
            ),

            const Divider(color: Colors.white30, thickness: 1),
            Expanded(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: chapters.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.white.withOpacity(0.8),
                  indent: 16,
                  endIndent: 16,
                ),
                itemBuilder: (context, index) {
                  final chapterItem = chapters[index];
                  final isCurrentChapter =
                      chapters[index].chapter_id == currentChapter;

                  return ListTile(
                    hoverColor: Colors.white.withOpacity(0.1),
                    selectedTileColor: AppColors.purple.withOpacity(0.2),
                    selected: isCurrentChapter,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: Container(
                      decoration: BoxDecoration(
                        color: isCurrentChapter
                            ? AppColors.purple.withOpacity(0.8)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.book_outlined,
                        color: isCurrentChapter ? Colors.white : Colors.white70,
                      ),
                    ),
                    title: Text(
                      'Chương ${index + 1}',
                      style: TextStyle(
                        color: isCurrentChapter
                            ? AppColors.purple.withOpacity(0.8)
                            : Colors.white70,
                        fontWeight: isCurrentChapter
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 18,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (chapterItem.is_vip)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ),
                        Icon(
                          Icons.remove_red_eye_outlined,
                          color: isCurrentChapter
                              ? AppColors.purple.withOpacity(0.8)
                              : Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          chapterItem.views.toString(),
                          style: TextStyle(
                            color: isCurrentChapter
                                ? AppColors.purple.withOpacity(0.8)
                                : Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    onTap: () => handleChapterNavigation(chapterItem),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
