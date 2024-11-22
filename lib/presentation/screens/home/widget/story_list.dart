import 'package:flutter/material.dart';
import 'package:story/core/utils/navigation_utils.dart';

import '../../../../models/story.dart';
import '../../detail_story/story_detail.dart';
import 'story_card_list.dart';

class StoryList extends StatelessWidget {
  final List<Story> stories;

  const StoryList({Key? key, required this.stories}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: stories.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            NavigationUtils.navigateTo(
                context,
                StoryDetailPage(
                  story_id: stories[index].story_id,
                  onShowComments: () {},
                ));
          },
          child: StoryCardList(
              image_path: stories[index].image_path,
              title: stories[index].title),
        );
      },
    );
  }
}
