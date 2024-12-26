import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../../../../models/story.dart';
import '../../../core/services/story_service.dart';
import '../../../core/utils/navigation_utils.dart';
import '../../widgets/show_more.dart';
import '../search/search.dart';
import 'widget/story_card.dart';
import 'widget/story_list.dart';

class NewStoryListPage extends StatefulWidget {
  const NewStoryListPage({super.key});

  @override
  _NewStoryListPageState createState() => _NewStoryListPageState();
}

class _NewStoryListPageState extends State<NewStoryListPage> {
  late Future<List<Story>> futureStories;
  late Future<List<Story>> futureStoryMostViews;
  final StoryService storyService = StoryService(); // Khởi tạo chỉ một lần

  @override
  void initState() {
    super.initState();
    futureStories = storyService.fetchStories();
    futureStoryMostViews = storyService.fetchStoryMostViews(5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Truyện Hot',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () =>
                NavigationUtils.navigateTo(context, SearchScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<List<Story>>>(
        future: Future.wait([futureStories, futureStoryMostViews]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có dữ liệu'));
          } else {
            final stories = snapshot.data![0]; // Tất cả truyện
            final mostReadStories =
                snapshot.data![1]; // Truyện có lượt xem cao nhất
            return Column(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: CarouselSlider.builder(
                    itemCount: mostReadStories.length,
                    itemBuilder: (context, index, realIndex) {
                      final story = mostReadStories[index];
                      return StoryCard(story: story);
                    },
                    options: CarouselOptions(
                        height: MediaQuery.of(context).size.height * 0.2,
                        viewportFraction: 1,
                        enlargeCenterPage: true,
                        autoPlay: true,
                        enableInfiniteScroll: true,
                        autoPlayAnimationDuration: const Duration(seconds: 3)),
                  ),
                ),
                ShowMore(
                  title: 'Lượt đọc',
                  onShowMore: () {},
                  border: true,
                ),
                Expanded(
                    child: StoryList(
                  stories: stories,
                )),
              ],
            );
          }
        },
      ),
    );
  }
}
