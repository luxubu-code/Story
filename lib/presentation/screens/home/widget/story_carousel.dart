import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:story/presentation/screens/home/widget/story_card.dart';

import '../../../../models/story.dart';

class StoryCarousel extends StatelessWidget {
  final List<Story> stories;

  const StoryCarousel({
    Key? key,
    required this.stories,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.2,
      child: CarouselSlider.builder(
        itemCount: stories.length,
        itemBuilder: (context, index, realIndex) {
          final story = stories[index];
          return StoryCard(story: story);
        },
        options: CarouselOptions(
          height: MediaQuery.of(context).size.height * 0.2,
          viewportFraction: 1,
          enlargeCenterPage: true,
          autoPlay: true,
          enableInfiniteScroll: true,
          autoPlayInterval: const Duration(milliseconds: 10000),
          // Dừng lại 10 giây
          autoPlayAnimationDuration:
              const Duration(milliseconds: 3000), // Thời gian chuyển
        ),
      ),
    );
  }
}
