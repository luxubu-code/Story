import 'package:flutter/material.dart';
import 'package:story/core/utils/navigation_utils.dart';

import '../../../../models/story.dart';
import '../../detail_story/detail_story_screen.dart';
import 'story_card_list.dart';

class StoryList extends StatelessWidget {
  final List<Story> stories;

  const StoryList({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: stories.length,
      itemBuilder: (BuildContext context, int index) {
        final story = stories[index];
        return GestureDetector(
          onTap: () {
            NavigationUtils.navigateTo(
                context,
                DetailStoryScreen(
                  story_id: story.story_id,
                  onShowComments: () {},
                ));
          },
          child: StoryCardList(
            image_path: story.image_path,
            title: story.title,
            is_vip: story.is_vip,
          ),
        );
      },
    );
  }
}
