import 'package:flutter/material.dart';

import '../../core/utils/dateTimeFormatUtils.dart';
import '../../models/story.dart';
import '../screens/detail_story/detail_story_screen.dart';

class ListStoryBuilder extends StatelessWidget {
  final List<Story> stories;
  final BuildContext context;

  const ListStoryBuilder(
      {super.key, required this.stories, required this.context});

  void toDetailStory(id) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailStoryScreen(
            story_id: id,
            onShowComments: () {},
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        return GestureDetector(
          onTap: () => toDetailStory(story.story_id),
          child: Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
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
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Cập nhật: ${time(story.updated_at)}',
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
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
        );
      },
    );
  }
}
