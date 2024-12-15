import 'dart:async';

import 'package:flutter/material.dart';
import 'package:story/core/constants/AppColors.dart';
import 'package:story/presentation/screens/detail_story/widget/body_chapter.dart';
import 'package:story/presentation/screens/detail_story/widget/body_rating.dart';

import '../../../core/services/story_service.dart';
import '../../../models/story.dart';
import 'widget/avatar_detail_story.dart';
import 'widget/body_detail.dart';

class DetailStoryScreen extends StatefulWidget {
  final int story_id;
  final VoidCallback onShowComments;

  const DetailStoryScreen(
      {super.key, required this.story_id, required this.onShowComments});

  @override
  _DetailStoryScreenState createState() => _DetailStoryScreenState();
}

class _DetailStoryScreenState extends State<DetailStoryScreen>
    with SingleTickerProviderStateMixin {
  late bool isExists;
  late Future<Story> futureStory;
  final StoryService storyService = StoryService();
  late TabController _tabController;
  static const List<Tab> myTabs = <Tab>[
    Tab(text: 'Chi tiết'),
    Tab(text: 'Đánh giá'),
    Tab(text: 'Danh sách chương'),
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
      backgroundColor: AppColors.thistle,
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
                        buildStat(
                            '${story.averageRating.toString()} ★', 'đánh giá'),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.grey[800],
                    child: TabBar(
                      dividerColor: AppColors.magentaPurple,
                      dividerHeight: 1,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.white,
                      tabs: myTabs,
                      controller: _tabController,
                      labelColor: AppColors.magentaPurple,
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        Container(
                          decoration: BoxDecoration(color: Colors.grey[800]),
                          child: SingleChildScrollView(
                            child: BodyDetail(
                              story_id: story.story_id,
                              status: story.status,
                              categories: story.categories,
                              description: story.description,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(color: Colors.grey[800]),
                          child: SingleChildScrollView(
                            child: BodyRating(story_id: story.story_id),
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
                  Container(
                    decoration: BoxDecoration(color: Colors.grey[800]),
                    padding: const EdgeInsets.all(8.0),
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        'Đọc truyện',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
