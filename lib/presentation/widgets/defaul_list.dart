import 'package:flutter/material.dart';
import 'package:story/core/utils/navigation_utils.dart';

import '../../models/story.dart';
import '../screens/detail_story/story_detail.dart';

class DefaulList extends StatefulWidget {
  final List<Story> stories;

  const DefaulList({super.key, required this.stories});

  @override
  State<DefaulList> createState() => _DefaulListState();
}

class _DefaulListState extends State<DefaulList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.stories.length,
      itemBuilder: (context, index) {
        final story = widget.stories[index];
        return GestureDetector(
          onTap: () => NavigationUtils.navigateTo(context,
              StoryDetailPage(story_id: story.story_id, onShowComments: () {})),
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
                        const SizedBox(height: 4),
                        Text(''),
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
