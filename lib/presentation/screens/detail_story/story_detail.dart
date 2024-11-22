import 'dart:async';

import 'package:flutter/material.dart';
import 'package:story/presentation/screens/detail_story/widget/body_chapter.dart';

import '../../../core/services/story_service.dart';
import '../../../models/story.dart';
import 'widget/avatar_detail_story.dart';
import 'widget/body_detail.dart';

class StoryDetailPage extends StatefulWidget {
  final int story_id;
  final VoidCallback onShowComments;

  const StoryDetailPage(
      {super.key, required this.story_id, required this.onShowComments});

  @override
  _StoryDetailPageState createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends State<StoryDetailPage>
    with SingleTickerProviderStateMixin {
  late bool isExists;
  late Future<Story> futureStory;
  final StoryService storyService = StoryService();
  late TabController _tabController;
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Detail'),
    Tab(text: 'Chapter'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    futureStory = storyService.fetchStoriesDetail(widget.story_id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<Story>(
        future: futureStory,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final story = snapshot.data!;
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.pinkAccent),
              ),
              child: Column(
                children: [
                  AvatarDetailStory(
                    image_path: story.image_path,
                    title: story.title,
                    author: story.author,
                    story_id: story.story_id,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10)),
                    ),
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        buildStat(story.favourite.toString(), 'Lượt thích'),
                        buildStat(story.views.toString(), 'Độ hot'),
                        buildStat('4,5 ★', '1183 người đánh giá'),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.grey[800],
                    child: TabBar(
                      dividerColor: Colors.pinkAccent,
                      dividerHeight: 2,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.white,
                      tabs: myTabs,
                      controller: _tabController,
                      labelColor: Colors.pinkAccent,
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Container(
                          decoration: BoxDecoration(color: Colors.grey[800]),
                          child: BodyDetail(
                            story_id: story.story_id,
                            status: story.status,
                            categories: story.categories,
                            description: story.description,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(color: Colors.grey[800]),
                          child: BodyChapter(
                            story_id: story.story_id,
                            chapters: story.chapters,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data available'));
          }
        },
      ),
    );
  }
}

Widget buildStat(String value, String label) {
  return Column(
    children: [
      Text(value,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(color: Colors.white70)),
    ],
  );
}
