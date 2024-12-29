import 'package:flutter/material.dart';
import 'package:story/core/utils/navigation_utils.dart';

import '../../../../core/constants/AppColors.dart';
import '../../../../core/utils/dateTimeFormatUtils.dart';
import '../../../../models/story.dart';
import '../../chapter/chapter_screen.dart';

class HistoryBuild extends StatelessWidget {
  final List<Story> stories;
  final BuildContext context;

  const HistoryBuild({super.key, required this.stories, required this.context});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        return GestureDetector(
          onTap: () => NavigationUtils.navigateTo(
            context,
            ChapterScreen(
              chapter_id: story.chapter_id,
              chapters: story.chapters,
              story_id: story.story_id,
            ),
          ),
          child: Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFe0c3fc),
                    Color(0xFF8ec5fc),
                  ], // Gradient pastel nhẹ
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.all(
                    Radius.circular(15)), // Bo tròn góc cho nền gradient
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        story.image_path,
                        width: 80,
                        height: 110,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80,
                            height: 110,
                            color: Colors.grey[200],
                            child: Icon(Icons.image,
                                size: 40, color: Colors.grey[400]),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.amethystPurple.withOpacity(0.1),
                              border:
                                  Border.all(color: AppColors.amethystPurple),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              story.categories[0].title.toString(),
                              style: const TextStyle(
                                color: AppColors.amethystPurple,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            story.title,
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Lần đọc cuối cùng: ${time((story.read_at))}',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cập nhật: ${time(story.updated_at)}',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.favorite, size: 18, color: Colors.grey[400]),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
